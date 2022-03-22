# frozen_string_literal: true

require "csv"

module Api
  module V1
    class TestECFParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiCsv
      include ApiFilter
      include Api::ParticipantActions

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

      def access_scope
        LeadProviderApiToken
          .joins(cpd_lead_provider: [:lead_provider])
          .where(private_api_access: true)
      end

      def lead_provider
        current_user.lead_provider
      end

      def induction_records
        scope = default_scope

        if updated_since.present?
          scope = scope
            .where(users: { updated_at: updated_since.. })
            .order("users.updated_at, users.id")
        end

        scope.order("users.created_at")
      end

      def default_scope
        @default_scope ||= InductionRecord
          .joins(induction_programme: { partnership: :lead_provider })
          .joins(participant_profile: %i[user participant_identity])
          .where(partnerships: { lead_provider: lead_provider })
          .includes(participant_profile: %i[
            participant_identity
            user
            cohort
            school
            ecf_participant_eligibility
            ecf_participant_validation_data
            schedule
            teacher_profile
            mentor
          ])
      end
    end
  end
end
