# frozen_string_literal: true

module Api
  module V1
    class ParticipantDeclarationsController < Api::ApiController
      include ApiTokenAuthenticatable

      def create
        params = HashWithIndifferentAccess.new({ raw_event: request.raw_post, lead_provider: current_user }).merge(permitted_params)
        return head(RecordParticipantEvent.call(params)) if check_config(params)

        raise ActionController::ParameterMissing, missing_params(params)
      end

    private

      def check_config(params)
        missing_params(params).empty?
      end

      def missing_params(params)
        required_params - params.keys
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
