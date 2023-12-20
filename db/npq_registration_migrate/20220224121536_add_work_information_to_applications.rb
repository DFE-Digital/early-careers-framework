class AddWorkInformationToApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :works_in_school, :boolean
    add_column :applications, :employer_name, :string
    add_column :applications, :employment_role, :string
  end
end
