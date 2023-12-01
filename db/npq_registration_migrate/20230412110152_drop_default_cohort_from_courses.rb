class DropDefaultCohortFromCourses < ActiveRecord::Migration[6.1]
  def up
    remove_column :courses, :default_cohort
  end

  def down
    add_column :courses, :default_cohort, :integer, default: 2022
  end
end
