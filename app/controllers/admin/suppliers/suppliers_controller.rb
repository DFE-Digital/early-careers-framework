# frozen_string_literal: true

module Admin
  module Suppliers
    class SuppliersController < Admin::BaseController
      skip_after_action :verify_authorized, only: :index

      def index
        lead_providers = policy_scope(LeadProvider)
        delivery_partners = policy_scope(DeliveryPartner)
        sorted_suppliers = (lead_providers + delivery_partners).sort_by(&:name)
        @suppliers = Kaminari.paginate_array(sorted_suppliers).page(params[:page]).per(20)
        @page = @suppliers.current_page
        @total_pages = @suppliers.total_pages
      end
    end
  end
end
