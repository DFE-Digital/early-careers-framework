# frozen_string_literal: true

require "csv"

module Api
  module V1
    class NPQApplicationsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiFilter

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

      def reject
        profile = npq_lead_provider.npq_applications.find(params[:id])

        if profile.update(lead_provider_approval_status: "rejected")
          render json: json_serializer_class.new(profile).serializable_hash
        else
          render json: { errors: Api::ErrorFactory.new(model: profile).call }, status: :bad_request
        end
      end

      def accept
        npq_application = npq_lead_provider.npq_applications.includes(:participant_identity, :npq_course).find(params[:id])
        if NPQ::Accept.call(npq_application:)
          render json: json_serializer_class.new(npq_application).serializable_hash
        else
          render json: { errors: Api::ErrorFactory.new(model: npq_application).call }, status: :bad_request
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
                  .includes(:cohort, :npq_course, participant_identity: [:user])
                  .where(cohort: with_cohorts)
        scope = scope.where("updated_at > ?", updated_since) if updated_since.present?
        scope
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:npq_lead_provider])
      end
    end
  end
end
