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
        scope = lead_provider.delivery_partners
        scope = scope.where("provider_relationships.cohort_id IN (?)", cohorts.map(&:id))
        scope = scope.order("delivery_partners.created_at ASC") if params[:sort].blank?
        scope.distinct
      end

      def delivery_partner
        lead_provider.delivery_partners.find(params[:id])
      end
    end
  end
end
