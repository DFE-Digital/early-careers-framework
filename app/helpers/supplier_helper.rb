# frozen_string_literal: true

module SupplierHelper
  def supplier_link(supplier)
    supplier.is_a?(LeadProvider) ? supplier.name : govuk_link_to(supplier.name, edit_admin_delivery_partner_path(supplier))
  end
end
