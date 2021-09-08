# frozen_string_literal: true

module Api
  module V1
    class ParticipantDeclarationsController < Api::ApiController
      include ApiAuditable
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiCsv
      include ApiFilter

      def create
        params = HashWithIndifferentAccess.new({ cpd_lead_provider: cpd_lead_provider }).merge(permitted_params["attributes"] || {})
        render json: RecordParticipantDeclaration.call(params)
      end

      def index
        respond_to do |format|
          format.json do
            participant_declarations_hash = ParticipantDeclarationSerializer.new(paginate(query_scope)).serializable_hash
            render json: participant_declarations_hash.to_json
          end
          format.csv do
            participant_declarations_hash = ParticipantDeclarationSerializer.new(query_scope).serializable_hash
            render body: to_csv(participant_declarations_hash)
          end
        end
      end

      def show
        record = ParticipantDeclaration.find_by(id: params[:id])

        if record.present?
          render json: ParticipantDeclarationSerializer.new(record).serializable_hash.to_json
        else
          head :not_found
        end
      end

    private

      def query_scope
        scope = ParticipantDeclaration.for_lead_provider(cpd_lead_provider)
        scope = scope.where("user_id = ?", participant_id_filter) if participant_id_filter.present?
        scope = scope.where("updated_at > ?", updated_since) if updated_since.present?
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

      def participant_declarations
        ParticipantDeclaration.for_lead_provider(cpd_lead_provider)
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
