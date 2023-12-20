class AddApplicationLeadProviderFk < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :applications, :lead_providers, column: :lead_provider_id
  end
end
