# frozen_string_literal: true

require "csv"

module Api
  module V1
    class ECFParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiCsv
      include ApiFilter
      include Api::ParticipantActions

      def index
        respond_to do |format|
          format.json do
            participant_hash = ParticipantSerializer.new(paginate(participants), { params: { mentor_ids: mentor_ids } }).serializable_hash
            render json: participant_hash.to_json
          end
          format.csv do
            participant_hash = ParticipantSerializer.new(participants, { params: { mentor_ids: mentor_ids } }).serializable_hash
            render body: to_csv(participant_hash)
          end
        end
      end

    private

      def serialized_response(profile)
        ParticipantSerializer
          .new(profile)
          .serializable_hash.to_json
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:lead_provider])
      end

      def lead_provider
        current_user.lead_provider
      end

      def participants
        participant_profiles = ParticipantProfile::ECF.where(id: participant_profile_ids)
                                                      .joins(:participant_identity, :user)
                                                      .includes(
                                                        :participant_identity,
                                                        :user,
                                                        :cohort,
                                                        :school,
                                                        :ecf_participant_eligibility,
                                                        :ecf_participant_validation_data,
                                                        :schedule,
                                                        :teacher_profile,
                                                      )

        if updated_since.present?
          participant_profiles = participant_profiles.where(user: { updated_at: updated_since.. })
                                                     .order("\"user\".updated_at, \"user\".id")
        end

        participant_profiles.order("\"user\".created_at")
      end

      def participant_profile_ids
        @participant_profile_ids ||= fetch_participant_profile_ids
      end

      def mentor_ids
        # I can't figure out a way to preload the mentor IDs with the other data here, since that would include two copies of the
        # users table, and active_record picks the wrong one. This horrible hack is to keep the number of db queries sane by
        # constructing a hash from profile ID to mentor ID in a single query
        ParticipantProfile::ECT.where(id: participant_profile_ids)
                               .joins(:mentor)
                               .pluck(:id, User.arel_table["id"])
                               .to_h
      end

      def fetch_participant_profile_ids
        # this retrieves the list of ECF participant profiles for the LeadProvider, one per
        # teacher_profile (now participant_identity).
        # Withdrawn profiles are included unless there is also an active one.
        # The DISTINCT ON clause chooses the first record after ordering by status to do this.
        inner_query = lead_provider
          .ecf_participant_profiles
          .select("DISTINCT ON (participant_profiles.participant_identity_id) participant_identity_id, participant_profiles.status, participant_profiles.id AS id")
          .joins(:school_cohort)
          .where(school_cohort: { cohort_id: Cohort.current.id })
          .order(:participant_identity_id, status: :asc)
          .to_sql
        ActiveRecord::Base.connection.query_values("SELECT id FROM (#{inner_query}) AS inner_query")
      end
    end
  end
end
