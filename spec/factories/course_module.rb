# frozen_string_literal: true

FactoryBot.define do
  factory :course_module do
    title { "Test Course module" }
    content { "No content" }
    course_year { FactoryBot.create(:course_year) }
  end
end
