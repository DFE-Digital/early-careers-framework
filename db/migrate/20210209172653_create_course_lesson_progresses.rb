# frozen_string_literal: true

class CreateCourseLessonProgresses < ActiveRecord::Migration[6.1]
  def change
    create_table :course_lesson_progresses, id: :uuid do |t|
      t.string :progress, default: "not_started"
      t.references :early_career_teacher_profile, null: false, foreign_key: true, index: { name: :idx_course_lesson_progresses_on_ect_profile_id }
      t.references :course_lesson, null: false, foreign_key: true, index: { name: :idx_course_lesson_progresses_on_course_lesson_id }
      t.timestamps
    end
  end
end
