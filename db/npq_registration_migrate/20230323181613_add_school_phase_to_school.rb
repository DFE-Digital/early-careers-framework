class AddSchoolPhaseToSchool < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :phase_type, :integer, default: 0
    add_column :schools, :phase_name, :string, default: "Not applicable"
  end
end
