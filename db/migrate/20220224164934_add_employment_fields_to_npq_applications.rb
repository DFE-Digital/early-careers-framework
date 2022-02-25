class AddEmploymentFieldsToNPQApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_applications, :works_in_school, :boolean
    add_column :npq_applications, :employer_name, :string
    add_column :npq_applications, :employment_role, :string
  end
end
