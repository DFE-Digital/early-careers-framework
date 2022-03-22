class AddUseVaultToCpdLeadProviders < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_column :cpd_lead_providers, :use_vault, :boolean, default: false
    end
  end
end
