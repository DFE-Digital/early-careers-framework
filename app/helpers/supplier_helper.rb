# frozen_string_literal: true

module SupplierHelper
  def supplier_link(supplier)
    govuk_link_to(supplier.name, supplier.is_a?(LeadProvider) ? admin_lead_provider_path(supplier) : edit_admin_delivery_partner_path(supplier))
  end
end
