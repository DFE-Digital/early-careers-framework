# frozen_string_literal: true

FactoryBot.define do
  factory :school_access_token do
    token { Faker::Alphanumeric.alphanumeric(number: 16) }
    permitted_actions { %i[some_action] }
    school

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :nearly_expired do
      expires_at { 1.day.from_now }
    end
  end
end
