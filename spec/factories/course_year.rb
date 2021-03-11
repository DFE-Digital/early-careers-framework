# frozen_string_literal: true

FactoryBot.define do
  factory :course_year do
    title { "Test Course year" }
    content { "No content" }
    is_year_one { true }
    core_induction_programme
  end
end
