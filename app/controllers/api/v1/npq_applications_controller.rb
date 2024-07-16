# frozen_string_literal: true

require "csv"
require "identity/transfer"

module Api
  module V1
    class NPQApplicationsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiFilter
      include ApiFilterValidation

      rescue_from Identity::TransferError, with: :identity_transfer_error_response

      def index
        respond_to do |format|
          format.json do
            render json: json_serializer_class.new(paginate(query_scope)).serializable_hash
          end

          format.csv do
            render body: csv_serializer_class.new(query_scope).call
          end
        end
      end

      def show
        render json: json_serializer_class.new(npq_application).serializable_hash
      end

      def reject
        service = ::NPQ::Application::Reject.new(npq_application:)

        render_from_service(service, json_serializer_class)
      end

      def accept
        service = ::NPQ::Application::Accept.new(npq_application:, funded_place:)

        render_from_service(service, json_serializer_class)
      end

      def change_funded_place
        if FeatureFlag.active?(:npq_capping)
          service = ::NPQ::Application::ChangeFundedPlace.new(npq_application:, funded_place:)

          render_from_service(service, json_serializer_class)
        else
          head :forbidden
        end
      end

    private

      def json_serializer_class
        NPQApplicationSerializer
      end

      def csv_serializer_class
        NPQApplicationCsvSerializer
      end

      def npq_lead_provider
        current_api_token.cpd_lead_provider.npq_lead_provider
      end

      def query_scope
        scope = npq_lead_provider
                  .npq_applications
                  .includes(:cohort, :npq_course, :profile, participant_identity: [:user])
                  .where(cohort: with_cohorts)
        scope = scope.where("updated_at > ?", updated_since) if updated_since.present?
        scope.order("npq_applications.created_at ASC")
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:npq_lead_provider])
      end

      def npq_application
        @npq_application ||= npq_lead_provider.npq_applications.includes(:cohort, :npq_course, participant_identity: [:user]).find(params[:id])
      end

      def funded_place
        if FeatureFlag.active?(:npq_capping)
          accept_permitted_params.dig("attributes", "funded_place")
        end
      end

      def accept_permitted_params
        parameters = params
          .fetch(:data)
          .permit(:type, attributes: %i[funded_place])

        return parameters unless parameters["attributes"].empty?

        raise ActionController::BadRequest, I18n.t(:invalid_data_structure)
      rescue ActionController::ParameterMissing
        {}
      end

      def identity_transfer_error_response(_exception)
        render json: { errors: Api::ParamErrorFactory.new(error: I18n.t(:application_not_accepted), params: I18n.t(:contact_us_to_resolve_issue)).call }, status: :unprocessable_entity
      end
    end
  end
end
