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
                                                      .joins(:user)
                                                      .includes(
                                                        :user,
                                                        :cohort,
                                                        :school,
                                                        :ecf_participant_eligibility,
                                                        :ecf_participant_validation_data,
                                                        :schedule,
                                                        teacher_profile: { current_ect_profile: { mentor_profile: :user } },
                                                      )

        if updated_since.present?
          participant_profiles = participant_profiles.where(user: { updated_at: updated_since.. })
                                                     .order("\"user\".updated_at, \"user\".id")
        end

        participant_profiles.order("\"user\".created_at")
      end

      def participant_profile_ids
        @participant_profile_ids ||= lead_provider.ecf_participant_profiles
                                                  .select("DISTINCT ON (participant_profiles.teacher_profile_id) teacher_profile_id, participant_profiles.status, participant_profiles.id")
                                                  .joins(:school_cohort)
                                                  .where(school_cohort: { cohort_id: Cohort.current.id })
                                                  .order(:teacher_profile_id, status: :asc)
                                                  .map(&:id)
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
    end
  end
end
