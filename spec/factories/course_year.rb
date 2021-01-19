# frozen_string_literal: true

FactoryBot.define do
  factory :course_year do
    title { "Test Course year" }
    content { "No content" }
    is_year_one { true }
    lead_provider { FactoryBot.create(:lead_provider) }
  end
end
