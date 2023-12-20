class AddDefaultCohortToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :default_cohort, :integer, default: 2022
  end
end
