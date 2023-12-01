class AddEmploymentTypeToApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :employment_type, :string
  end
end
