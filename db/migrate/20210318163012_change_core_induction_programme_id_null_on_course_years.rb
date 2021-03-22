# frozen_string_literal: true

class ChangeCoreInductionProgrammeIdNullOnCourseYears < ActiveRecord::Migration[6.1]
  def self.up
    change_column_null :course_years, :core_induction_programme_id, false
  end

  def self.down
    change_column_null :course_years, :core_induction_programme_id, true
  end
end
