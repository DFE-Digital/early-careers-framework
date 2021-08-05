# frozen_string_literal: true

require "csv"

module Api
  module V1
    class NPQApplicationsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination

      def index
        respond_to do |format|
          format.json do
            render json: NPQApplicationSerializer.new(paginate(query_scope)).serializable_hash
          end

          format.csv do
            render body: NPQApplicationCsvSerializer.new(query_scope).call
          end
        end
      end

      def reject
        profile = npq_lead_provider.npq_profiles.includes(:user, :npq_course).find(params[:id])

        if profile.update(lead_provider_approval_status: "rejected")
          render json: NPQApplicationSerializer.new(profile).serializable_hash
        else
          render json: { errors: Api::ErrorFactory.new(model: profile).call }, status: :bad_request
        end
      end

      def accept
        profile = npq_lead_provider.npq_profiles.includes(:user, :npq_course).find(params[:id])
        other_profiles = NPQValidationData.where(profile: (profile.user.npq_profiles - [profile.profile]))

        ActiveRecord::Base.transaction do
          if profile.update(lead_provider_approval_status: "accepted") && other_profiles.update(lead_provider_approval_status: "rejected")
            render json: NPQApplicationSerializer.new(profile).serializable_hash
          else
            render json: { errors: Api::ErrorFactory.new(model: profile).call }, status: :bad_request
          end
        end
      end

    private

      def npq_lead_provider
        current_api_token.cpd_lead_provider.npq_lead_provider
      end

      def query_scope
        scope = npq_lead_provider.npq_profiles.includes(:user, :npq_course)
        scope = scope.where("updated_at > ?", Time.iso8601(updated_since_filter)) if updated_since_filter.present?
        scope
      end

      def filter
        params[:filter] ||= {}
      end

      def updated_since_filter
        filter[:updated_since]
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:npq_lead_provider])
      end
    end
  end
end
