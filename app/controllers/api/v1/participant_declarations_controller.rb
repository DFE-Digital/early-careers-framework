# frozen_string_literal: true

module Api
  module V1
    class ParticipantDeclarationsController < Api::ApiController
      include ApiTokenAuthenticatable

      def create
        config = HashWithIndifferentAccess.new({ raw_event: request.raw_post, lead_provider: current_user }).merge(permitted_params)
        return head(RecordParticipantEvent.call(config)) if check_config(config)

        raise ActionController::ParameterMissing, missing_params(config)
      end

    private

      def check_config(config)
        missing_params(config).empty?
      end

      def missing_params(config)
        required_params - config.keys
      end

      def permitted_params
        params.permit(*required_params)
      end

      def required_params
        %w[participant_id declaration_date declaration_type]
      end
    end
  end
end
