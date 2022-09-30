# frozen_string_literal: true

module Api
  module V3
    class DeliveryPartnersController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiFilter
      include ApiOrderable

      # Returns a list of delivery partners
      # Providers can see their delivery partners and which cohorts they apply to via this endpoint
      #
      # GET /api/v3/delivery-partners?filter[cohort]=2021,2022&sort=name,-updated_at
      #
      def index
        render json: serializer_class.new(paginate(delivery_partners)).serializable_hash.to_json
      end

    private

      def delivery_partners
        DeliveryPartner.where(provider_relationships:).order(sort_params(params))
      end

      def provider_relationships
        scope = lead_provider.provider_relationships
        scope = scope.where(cohort: with_cohorts) if filter[:cohort].present?
        scope
      end

      def lead_provider
        current_api_token.cpd_lead_provider.lead_provider
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:lead_provider])
      end

      def serializer_class
        Api::V3::DeliveryPartnerSerializer
      end
    end
  end
end
