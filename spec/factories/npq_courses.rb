# frozen_string_literal: true

FactoryBot.define do
  factory :npq_course do
    sequence(:name) { |n| "NPQ Course #{n}" }
  end
end
