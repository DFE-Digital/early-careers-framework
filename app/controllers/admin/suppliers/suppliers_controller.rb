# frozen_string_literal: true

module Admin
  module Suppliers
    class SuppliersController < Admin::BaseController
      skip_after_action :verify_authorized, only: :index

      def index
        suppliers_search = delivery_partners_search + lead_providers_search
        @query = params[:query]
        @pagy, @suppliers = pagy_array(suppliers_search, page: params[:page], items: 20)
        @page = @pagy.page
        @total_pages = @pagy.pages
      end

    private

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
