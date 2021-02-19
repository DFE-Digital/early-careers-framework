# frozen_string_literal: true

FactoryBot.define do
  factory :course_lesson_part do
    title { "Test Course lesson part" }
    content { "No content" }
    course_lesson
  end
end
