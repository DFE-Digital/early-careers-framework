# frozen_string_literal: true

module Api
  module V1
    class ParticipantDeclarationsController < Api::ApiController
      include ApiTokenAuthenticatable

      def create
        params = HashWithIndifferentAccess.new({ lead_provider_from_token: cpd_lead_provider }).merge(permitted_params["attributes"] || {})
        validate_params!(params)
        render json: RecordParticipantDeclaration.call(convert_params_for_declaration(params))
      end

    private

      def cpd_lead_provider
        current_user
      end

      def convert_params_for_declaration(params)
        params.transform_keys do |key|
          key == "participant_id" ? "user_id" : key
        end
      end

      def validate_params!(params)
        raise ActionController::ParameterMissing, missing_params(params) unless missing_params(params).empty?
      end

      def missing_params(params)
        required_params - params.keys
      end

      def permitted_params
        params.require(:data).permit(:type, { attributes: required_params + optional_params })
      rescue ActionController::ParameterMissing => e
        if e.param == :data
          raise ActionController::BadRequest, I18n.t(:invalid_data_structure)
        else
          raise
        end
      end

      def optional_params
        %w[evidence_held]
      end

      def required_params
        %w[participant_id declaration_date declaration_type course_identifier]
      end
    end
  end
end
