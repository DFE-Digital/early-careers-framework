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
            participant_hash = ParticipantSerializer.new(paginate(participant_profiles)).serializable_hash
            render json: participant_hash.to_json
          end

          format.csv do
            participant_hash = ParticipantSerializer.new(participant_profiles).serializable_hash
            render body: to_csv(participant_hash)
          end
        end
      end

    private

      def participant_profiles
        join = InductionRecord
          .select("induction_records.id, induction_records.participant_profile_id, MAX(induction_records.created_at), lead_providers.id AS lead_provider_id, schedules.cohort_id")
          .joins(:schedule, induction_programme: { partnership: :lead_provider })
          .group("induction_records.id, induction_records.participant_profile_id, lead_providers.id, schedules.cohort_id")

        query = ParticipantProfile
          .joins("JOIN (#{join.to_sql}) AS ir ON ir.participant_profile_id = participant_profiles.id")
          .where("ir.lead_provider_id = ? AND ir.cohort_id IN (?)", lead_provider.id, with_cohorts.map(&:id))
        query.order
      end

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
    end
  end
end
