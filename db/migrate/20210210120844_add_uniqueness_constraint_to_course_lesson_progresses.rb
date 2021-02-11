# frozen_string_literal: true

class AddUniquenessConstraintToCourseLessonProgresses < ActiveRecord::Migration[6.1]
  def change
    change_table :course_lesson_progresses do |t|
      t.index %w[course_lesson_id early_career_teacher_profile_id], unique: true, name: "idx_cl_progresses_on_cl_id_and_ect_profile_id"
    end
  end
end
