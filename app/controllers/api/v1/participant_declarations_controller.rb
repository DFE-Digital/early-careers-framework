# frozen_string_literal: true

module Api
  module V1
    class ParticipantDeclarationsController < Api::ApiController
      include ApiAuditable
      include ApiTokenAuthenticatable
      include ApiPagination

      def create
        params = HashWithIndifferentAccess.new({ cpd_lead_provider: cpd_lead_provider }).merge(permitted_params["attributes"] || {})
        render json: RecordParticipantDeclaration.call(params)
      end

      def index
        participant_declarations_hash = ParticipantDeclarationSerializer.new(paginate(query_scope)).serializable_hash
        render json: participant_declarations_hash.to_json
      end

    private

      def query_scope
        scope = ParticipantDeclaration.for_lead_provider(cpd_lead_provider)
        scope = scope.where("user_id = ?", participant_id_filter) if participant_id_filter.present?
        scope
      end

      def filter
        params[:filter] ||= {}
      end

      def participant_id_filter
        filter[:participant_id]
      end

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
