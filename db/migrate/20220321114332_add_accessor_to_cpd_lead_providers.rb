class AddAccessorToCpdLeadProviders < ActiveRecord::Migration[6.1]
  def change
    add_column :cpd_lead_providers, :accessor, :string
  end
end
