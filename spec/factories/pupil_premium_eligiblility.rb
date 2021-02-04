# frozen_string_literal: true

FactoryBot.define do
  factory :pupil_premium_eligibility do
    start_year { 2021 }
    percent_primary_pupils_eligible { Faker::Number.between(from: 0.0, to: 100.0) }
    percent_secondary_pupils_eligible { Faker::Number.between(from: 0.0, to: 100.0) }

    trait :eligible do
      percent_primary_pupils_eligible { Faker::Number.between(from: 40.0, to: 100.0) }
    end

    trait :not_eligible do
      percent_primary_pupils_eligible { Faker::Number.between(from: 0.0, to: 39.9) }
      percent_secondary_pupils_eligible { Faker::Number.between(from: 0.0, to: 39.9) }
    end
  end
end
