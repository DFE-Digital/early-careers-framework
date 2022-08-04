# frozen_string_literal: true

require "csv"

module Api
  module V1
    class ParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ParticipantActions

    private

      def serialized_response(profile)
        relevant_induction_record = profile.relevant_induction_record(lead_provider:)

        ParticipantFromInductionRecordSerializer
          .new(relevant_induction_record, params: { lead_provider: })
          .serializable_hash.to_json
      end

      def lead_provider
        current_user.lead_provider
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:lead_provider])
      end
    end
  end
end
