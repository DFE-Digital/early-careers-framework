# frozen_string_literal: true

module SupplierHelper
  def supplier_link(supplier)
    supplier.instance_of?(LeadProvider) ? nil : admin_delivery_partner_path(supplier)
  end
end
