# frozen_string_literal: true

module Api
  module V1
    class ParticipantDeclarationsController < Api::ApiController
      include ActionController::StrongParameters
      include ApiTokenAuthenticatable
      wrap_parameters format: [:json]

      def create
        config = HashWithIndifferentAccess.new({ raw_event: request.raw_post, lead_provider: current_user }).merge(declaration_params)
        return head(RecordParticipantEvent.call(config)) if check_config(config)

        raise ActionController::ParameterMissing, missing_params(config)
      end

    private

      def permitted_params
        RecordParticipantEvent.required_params
      end

      def required_params
        %w[participant_id declaration_date declaration_type]
      end

      def missing_params(config)
        required_params - config.keys
      end

      def check_config(config)
        missing_params(config).empty?
      end

      def declaration_params
        params.permit(:participant_id, :declaration_date, :declaration_type)
      end
    end
  end
end
