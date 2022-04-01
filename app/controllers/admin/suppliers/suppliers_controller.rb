# frozen_string_literal: true

module Admin
  module Suppliers
    class SuppliersController < Admin::BaseController
      skip_after_action :verify_authorized, only: :index

      def index
        lead_providers = policy_scope(LeadProvider).sort_by(&:name)
        delivery_partners = policy_scope(DeliveryPartner).sort_by(&:name)
        sorted_suppliers = (lead_providers + delivery_partners)
        @suppliers = Kaminari.paginate_array(sorted_suppliers).page(params[:page]).per(5)
        @page = @suppliers.current_page
        @total_pages = @suppliers.total_pages
        @pagy, @suppliers2 = pagy_array(sorted_suppliers, page: params[:page], items: 5)
        # @page = @pagy.page
        # @total_pages = @pagy.pages
      end
    end
  end
end
