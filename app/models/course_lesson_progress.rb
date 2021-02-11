# frozen_string_literal: true

class CourseLessonProgress < ApplicationRecord
  enum progress: { not_started: "not_started", complete: "complete" }

  belongs_to :course_lesson
  belongs_to :early_career_teacher_profile

  validates :course_lesson_id, uniqueness: { scope: :early_career_teacher_profile_id }
end
