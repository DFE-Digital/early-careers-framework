# frozen_string_literal: true

module Api
  module V3
    class ParticipantDeclarationsController < Api::ApiController
      include ApiAuditable
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiFilter

      # Returns a list of participant declarations
      #
      # GET /api/v3/participant-declarations?filter[cohort]=2021,2022
      #
      def index
        render json: serializer_class.new(paginate(participant_declarations)).serializable_hash.to_json
      end

      # Creates new participant declaration
      #
      # POST /api/v3/participant-declarations
      #
      def create
        service = RecordDeclaration.new({ cpd_lead_provider: }.merge(permitted_params["attributes"] || {}))

        log_schema_validation_results

        render_from_service(service, serializer_class)
      end

      # Returns a single participant declaration
      #
      # GET /api/v3/participant-declarations/:id
      #
      def show
        render json: serializer_class.new(participant_declaration).serializable_hash.to_json
      end

      # Void a participant declaration
      #
      # PUT /api/v3/participant-declarations/:id/void
      #
      def void
        render json: serializer_class.new(VoidParticipantDeclaration.new(participant_declaration).call).serializable_hash.to_json
      end

    private

      def cpd_lead_provider
        current_user
      end

      def participant_declarations
        @participant_declarations ||= participant_declarations_query.participant_declarations
      end

      def participant_declarations_query
        ParticipantDeclarationsQuery.new(
          cpd_lead_provider:,
          params: query_params,
        )
      end

      def query_params
        params.permit(:id, filter: %i[cohort participant_id updated_since delivery_partner_id])
      end

      def permitted_params
        params
          .require(:data)
          .permit(:type, attributes: %i[course_identifier declaration_date declaration_type participant_id evidence_held has_passed])
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

      def participant_declaration
        @participant_declaration ||= ParticipantDeclaration.for_lead_provider(cpd_lead_provider).find(params[:id])
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:lead_provider])
      end

      def serializer_class
        ParticipantDeclarationSerializer
      end
    end
  end
end
