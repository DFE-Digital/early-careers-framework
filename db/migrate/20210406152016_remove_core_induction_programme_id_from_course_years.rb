# frozen_string_literal: true

class RemoveCoreInductionProgrammeIdFromCourseYears < ActiveRecord::Migration[6.1]
  def change
    remove_column :course_years, :core_induction_programme_id, :uuid
  end
end
