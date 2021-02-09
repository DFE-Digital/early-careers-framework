# frozen_string_literal: true

FactoryBot.define do
  factory :course_lesson do
    title { "Test Course lesson" }
    content { "No content" }
    course_module { FactoryBot.create(:course_module) }
  end
end
