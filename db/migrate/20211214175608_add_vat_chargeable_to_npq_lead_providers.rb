# frozen_string_literal: true

class AddVatChargeableToNPQLeadProviders < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_lead_providers, :vat_chargeable, :boolean, default: true
  end
end
