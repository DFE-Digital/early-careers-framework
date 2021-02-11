# frozen_string_literal: true

class CourseLessonProgress < ApplicationRecord
  belongs_to :course_lesson
  belongs_to :early_career_teacher_profile

  validates :course_lesson_id, uniqueness: { scope: :early_career_teacher_profile_id }
  validates :progress, inclusion: { in: %w[not_started complete] }
end
