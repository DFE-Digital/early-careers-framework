# frozen_string_literal: true

module Api
  module V1
    class ParticipantDeclarationsController < Api::ApiController
      include ApiTokenAuthenticatable

      def create
        params = HashWithIndifferentAccess.new({ raw_event: request.raw_post, lead_provider: lead_provider }).merge(permitted_params["attributes"] || {})
        validate_params!(params)
        render json: RecordParticipantDeclaration.call(params)
      end

    private

      def lead_provider
        current_user.lead_provider
      end

      def validate_params!(params)
        raise ActionController::ParameterMissing, missing_params(params) unless missing_params(params).empty?
      end

      def missing_params(params)
        required_params - params.keys
      end

      def permitted_params
        params.require(:data).permit(:type, { attributes: required_params })
      rescue ActionController::ParameterMissing => e
        if e.param == :data
          raise ActionController::BadRequest, I18n.t(:invalid_data_structure)
        else
          raise
        end
      end

      def required_params
        %w[participant_id declaration_date declaration_type course_type]
      end
    end
  end
end
