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
        params = HashWithIndifferentAccess.new({ cpd_lead_provider: }).merge(permitted_params["attributes"] || {})

        log_schema_validation_results

        render json: RecordParticipantDeclaration.call(params)
      end

      def index
        respond_to do |format|
          format.json do
            participant_declarations_hash = serializer_class.new(paginate(query_scope)).serializable_hash
            render json: participant_declarations_hash.to_json
          end

          format.csv do
            participant_declarations_hash = serializer_class.new(query_scope).serializable_hash
            render body: to_csv(participant_declarations_hash)
          end
        end
      end

      def show
        render json: serializer_class.new(participant_declaration).serializable_hash.to_json
      end

      def void
        render json: serializer_class.new(VoidParticipantDeclaration.new(participant_declaration:).call).serializable_hash.to_json
      end

    private

      def serializer_class
        ParticipantDeclarationSerializer
      end

      def query_scope
        ParticipantDeclarations::Index.new(
          cpd_lead_provider:,
          updated_since:,
          participant_id: participant_id_filter,
        ).scope
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

      def participant_declaration
        @participant_declaration ||= ParticipantDeclaration.for_lead_provider(cpd_lead_provider).find(params[:id])
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

      def log_schema_validation_results
        errors = SchemaValidator.call(raw_event: request.raw_post)

        if errors.blank?
          Rails.logger.info "Passed schema validation"
        else
          Rails.logger.info "Failed schema validation for #{request.raw_post}"
          Rails.logger.info errors
        end
      rescue StandardError => e
        Rails.logger.info "Error on schema validation, #{e}"
      end
    end
  end
end
