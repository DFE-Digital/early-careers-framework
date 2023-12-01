class AddCohortToApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :cohort, :integer, default: 2021
  end
end
