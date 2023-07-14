# frozen_string_literal: true

module Api
  module V3
    class DeliveryPartnersQuery
      include Concerns::FilterCohorts

      attr_reader :lead_provider, :params

      def initialize(lead_provider:, params:)
        @lead_provider = lead_provider
        @params = params
      end

      def delivery_partners
        lead_provider
          .delivery_partners
          .where("provider_relationships.cohort_id IN (?)", cohorts.map(&:id))
          .order(sort_order)
          .distinct
      end

      def delivery_partner
        lead_provider.delivery_partners.find(params[:id])
      end

    private

      def sort_order
        params[:sort].presence || "delivery_partners.created_at ASC"
      end
    end
  end
end
