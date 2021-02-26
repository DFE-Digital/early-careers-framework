# frozen_string_literal: true

class CourseLessonProgress < ApplicationRecord
  enum progress: {
    not_started: "not_started",
    in_progress: "in_progress",
    discussion_needed: "discussion_needed",
    complete: "complete",
  }

  belongs_to :course_lesson
  belongs_to :early_career_teacher_profile
  has_one :user, through: :early_career_teacher_profile

  validates :course_lesson_id, uniqueness: { scope: :early_career_teacher_profile_id }
end
