# frozen_string_literal: true

class RemoveEngageAndLearnTables < ActiveRecord::Migration[6.1]
  def change
    remove_reference :course_lessons, :previous_lesson
    remove_reference :course_lessons, :course_module
    remove_reference :course_modules, :previous_module
    remove_reference :course_modules, :course_year
    remove_reference :course_years, :core_induction_programme

    # rubocop:disable all
    drop_table :course_years
    drop_table :course_modules
    drop_table :course_lessons
    # rubocop:enable :all
  end
end
