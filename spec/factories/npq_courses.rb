# frozen_string_literal: true

FactoryBot.define do
  factory :npq_course do
    sequence(:name) { |n| "NPQ Course #{n}" }
    sequence(:identifier) { |n| "npq-course-#{n}" }
  end
end
