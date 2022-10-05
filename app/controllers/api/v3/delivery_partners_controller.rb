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
        render json: serializer_class.new(paginate(delivery_partners), params: { lead_provider: }).serializable_hash.to_json
      end

      # Returns a specific delivery partner given its ID
      # Providers can see a specific delivery partner and which cohorts it applies to via this endpoint
      #
      # GET /api/v3/delivery-partners/:id
      #
      def show
        render json: serializer_class.new(delivery_partner).serializable_hash.to_json
      end

    private

      def lead_provider
        @lead_provider ||= current_user.lead_provider
      end

      def delivery_partners
        @delivery_partners ||= delivery_partners_query.delivery_partners.order(sort_params(params))
      end

      def delivery_partner
        @delivery_partner ||= delivery_partner_query.delivery_partner
      end

      def delivery_partner_query
        Api::V3::DeliveryPartners::Show.new(
          lead_provider:,
          params: delivery_partner_params,
        )
      end

      def delivery_partners_query
        Api::V3::DeliveryPartnersQuery.new(
          lead_provider:,
          params: delivery_partner_params,
        )
      end

      def delivery_partner_params
        params.permit(:id, :sort, filter: %i[cohort])
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
