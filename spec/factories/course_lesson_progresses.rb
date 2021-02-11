# frozen_string_literal: true

FactoryBot.define do
  factory :course_lesson_progress do
    progress { "not_started" }
    course_lesson
    early_career_teacher_profile
  end
end
