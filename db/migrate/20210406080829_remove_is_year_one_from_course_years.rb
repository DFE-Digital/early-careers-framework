# frozen_string_literal: true

class RemoveIsYearOneFromCourseYears < ActiveRecord::Migration[6.1]
  def change
    remove_column :course_years, :is_year_one, :boolean
  end
end
