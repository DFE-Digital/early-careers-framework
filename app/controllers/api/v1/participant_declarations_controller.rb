# frozen_string_literal: true

module Api
  module V1
    class ParticipantDeclarationsController < Api::ApiController
      include ApiAuditable
      include ApiTokenAuthenticatable

      def create
        params = HashWithIndifferentAccess.new({ cpd_lead_provider: cpd_lead_provider }).merge(permitted_params["attributes"] || {})
        render json: RecordParticipantDeclaration.call(params)
      end

    private

      def cpd_lead_provider
        current_user
      end

      def permitted_params
        params.require(:data).permit(:type, attributes: {})
      rescue ActionController::ParameterMissing => e
        if e.param == :data
          raise ActionController::BadRequest, I18n.t(:invalid_data_structure)
        else
          raise
        end
      end
    end
  end
end
