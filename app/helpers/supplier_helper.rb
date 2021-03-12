# frozen_string_literal: true

module SupplierHelper
  def supplier_link(supplier)
    supplier.is_a?(LeadProvider) ? nil : edit_admin_delivery_partner_path(supplier)
  end
end
