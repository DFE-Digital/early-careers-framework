# frozen_string_literal: true

require "csv"

module Api
  module V1
    class ParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ParticipantActions

      def change_schedule
        service = recorder(service_namespace: ::Participants::ChangeSchedule).new(params: params_for_recorder)
        result = service.call
        render json: serialized_response(result)
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
    end
  end
end
