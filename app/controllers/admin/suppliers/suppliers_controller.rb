# frozen_string_literal: true

module Admin
  module Suppliers
    class SuppliersController < Admin::BaseController
      skip_after_action :verify_authorized, only: :index

      def index
        @query = params[:query]
        @type = params[:type]
        @pagy, @suppliers = pagy_array(suppliers_search, page: params[:page], items: 20)
        @page = @pagy.page
        @total_pages = @pagy.pages
      end

    private

      def suppliers_search
        return delivery_partners_search if params[:type] == "delivery_partner"
        return lead_providers_search if params[:type] == "lead_provider"

        delivery_partners_search + lead_providers_search
      end

      def delivery_partners_search
        ::DeliveryPartners::SearchQuery
          .new(query: params[:query], scope: policy_scope(DeliveryPartner))
          .call
      end

      def lead_providers_search
        ::LeadProviders::SearchQuery
          .new(query: params[:query], scope: policy_scope(LeadProvider))
          .call
      end
    end
  end
end
