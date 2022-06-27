# frozen_string_literal: true

require "csv"

module Api
  module V1
    class ECFParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiCsv
      include ApiFilter
      include ParticipantActions

      def index
        respond_to do |format|
          format.json do
            participant_hash = ParticipantFromInductionRecordSerializer.new(paginate(induction_records)).serializable_hash
            render json: participant_hash.to_json
          end
          format.csv do
            participant_hash = ParticipantFromInductionRecordSerializer.new(induction_records).serializable_hash
            render body: to_csv(participant_hash)
          end
        end
      end

    private

      def serialized_response(profile)
        relevant_induction_record = profile.relevant_induction_record(lead_provider:)

        ParticipantFromInductionRecordSerializer
          .new(relevant_induction_record)
          .serializable_hash.to_json
      end

      def access_scope
        LeadProviderApiToken
          .joins(cpd_lead_provider: [:lead_provider])
      end

      def lead_provider
        current_user.lead_provider
      end

      def induction_records
        scope = InductionRecord
          .where(id: induction_record_ids_with_deduped_profiles)
          .joins(participant_profile: { school_cohort: [:cohort] })
          .where(participant_profile: { school_cohorts: { cohort: with_cohorts } })
          .includes(
            :schedule,
            induction_programme: {
              school_cohort: %i[
                cohort
                school
              ],
            },
            mentor_profile: [
              :participant_identity,
            ],
            participant_profile: %i[
              participant_identity
              user
              ecf_participant_eligibility
              ecf_participant_validation_data
              teacher_profile
            ],
          )

        if updated_since.present?
          scope
            .where(users: { updated_at: updated_since.. })
            .order("induction_records.updated_at, users.id")
        else
          scope.order("induction_records.created_at")
        end
      end

      # inner most query
      # this query deals with the following scenario
      # given one profile with 2 induction records
      # we only want to return the latest induction record
      # we also exclude any partnerships that have been challenged
      def induction_record_ids_with_deduped_induction_records
        query = InductionRecord
          .joins(induction_programme: { partnership: %i[lead_provider cohort] })
          .joins(participant_profile: %i[user participant_identity])
          .select("DISTINCT ON (participant_profiles.id) participant_profile_id, induction_records.id")
          .where(
            induction_programme: {
              partnerships: {
                challenged_at: nil,
                challenge_reason: nil,
                lead_provider:,
                cohort: with_cohorts,
              },
            },
          )
          .order("participant_profiles.id", start_date: :desc)
          .to_sql

        ActiveRecord::Base.connection.query_values("SELECT id FROM (#{query}) AS inner_query")
      end

      # second inner most query
      # this query deals with where a user can have multiple profiles
      # the work to map one user to one profile has not been done
      # therefore we must work around and select correct profile
      def induction_record_ids_with_deduped_profiles
        query = InductionRecord
          .where(id: induction_record_ids_with_deduped_induction_records)
          .joins(participant_profile: [:participant_identity])
          .select("DISTINCT ON (participant_profiles.participant_identity_id) participant_identity_id, induction_records.training_status, participant_profiles.created_at, induction_records.id")
          .order("participant_profiles.participant_identity_id", "induction_records.training_status ASC", "participant_profiles.created_at DESC")
          .to_sql

        ActiveRecord::Base.connection.query_values("SELECT id FROM (#{query}) AS inner_query")
      end
    end
  end
end
