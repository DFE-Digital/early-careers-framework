class AddFundingFieldsToApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :eligible_for_funding, :boolean, null: false, default: false
    add_column :applications, :funding_choice, :text
  end
end
