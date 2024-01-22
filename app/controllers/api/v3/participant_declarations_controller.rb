# frozen_string_literal: true

module Api
  module V3
    class ParticipantDeclarationsController < Api::ApiController
      include ApiAuditable
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiFilterValidation

      # Returns a list of participant declarations
      #
      # GET /api/v3/participant-declarations?filter[cohort]=2021,2022
      #
      def index
        if params[:use_proxy] == "yes"
          participant_declarations_hash = serializer_class.new(participant_declarations).serializable_hash

          res = NPQRegistrationProxy.new(request).perform
          npq_declarations = JSON.parse(res.body)

          combined = {
            data: (
              participant_declarations_hash[:data] + npq_declarations["data"]
            ),
          }

          render json: combined.to_json
        else
          render json: serializer_class.new(participant_declarations).serializable_hash.to_json
        end
      end

      # Creates new participant declaration
      #
      # POST /api/v3/participant-declarations
      #
      def create
        attributes = permitted_params["attributes"] || {}

        if params[:use_proxy] == "yes" && attributes[:course_identifier].to_s.starts_with?("npq-")
          res = NPQRegistrationProxy.new(request).perform

          render json: res.body
        else
          service = RecordDeclaration.new({ cpd_lead_provider: }.merge(attributes))

          log_schema_validation_results

          render_from_service(service, serializer_class)
        end
      end

      # Returns a single participant declaration
      #
      # GET /api/v3/participant-declarations/:id
      #
      def show
        if params[:use_proxy] == "yes"
          res = NPQRegistrationProxy.new(request).perform

          if res.is_a?(Net::HTTPSuccess)
            # Found in NPQ app
            render json: res.body
          else
            # Not found in NPQ app
            render json: serializer_class.new(participant_declaration_from_query).serializable_hash.to_json
          end
        else
          render json: serializer_class.new(participant_declaration_from_query).serializable_hash.to_json
        end
      end

      # Void a participant declaration
      #
      # PUT /api/v3/participant-declarations/:id/void
      #
      def void
        if params[:use_proxy] == "yes"
          res = NPQRegistrationProxy.new(request).perform

          if res.is_a?(Net::HTTPSuccess)
            # Found in NPQ app
            render json: res.body
          else
            # Not found in NPQ app
            render json: serializer_class.new(participant_declaration_from_query).serializable_hash.to_json
          end
        else
          render json: serializer_class.new(VoidParticipantDeclaration.new(participant_declaration_for_lead_provider).call).serializable_hash.to_json
        end
      end

    private

      def cpd_lead_provider
        current_user
      end

      def paginated_results
        paginate(participant_declarations_query.participant_declarations_for_pagination)
      end

      def participant_declarations
        @participant_declarations ||= participant_declarations_query.participant_declarations_from(paginated_results)
      end

      def participant_declarations_query
        ParticipantDeclarationsQuery.new(
          cpd_lead_provider:,
          params: query_params,
          use_proxy: (params[:use_proxy] == "yes"),
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

      def participant_declaration_from_query
        @participant_declaration_from_query ||= participant_declarations_query.participant_declaration(params[:id])
      end

      def participant_declaration_for_lead_provider
        @participant_declaration_for_lead_provider ||= ParticipantDeclaration.for_lead_provider(cpd_lead_provider).find(params[:id])
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:lead_provider]) + LeadProviderApiToken.joins(cpd_lead_provider: [:npq_lead_provider])
      end

      def serializer_class
        ParticipantDeclarationSerializer
      end
    end
  end
end
