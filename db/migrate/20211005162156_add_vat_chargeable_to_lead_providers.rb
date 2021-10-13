# frozen_string_literal: true

class AddVatChargeableToLeadProviders < ActiveRecord::Migration[6.1]
  def change
    add_column :lead_providers, :vat_chargeable, :boolean, default: true
  end
end
