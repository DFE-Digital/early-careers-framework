# frozen_string_literal: true

module PathHelper
  def show_supplier_path(supplier)
    supplier.instance_of?(LeadProvider) ? admin_show_lead_provider_path(supplier) : admin_show_delivery_partner_path(supplier)
  end

  def edit_supplier_path(supplier)
    supplier.instance_of?(LeadProvider) ? admin_edit_lead_provider_path(supplier) : admin_edit_delivery_partner_path(supplier)
  end
end
