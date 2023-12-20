class AddEarlyYearsColumnsToApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :private_childcare_provider_urn, :text
    add_column :applications, :works_in_nursery, :boolean
    add_column :applications, :works_in_childcare, :boolean
    add_column :applications, :kind_of_nursery, :text
  end
end
