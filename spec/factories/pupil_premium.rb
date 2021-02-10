# frozen_string_literal: true

FactoryBot.define do
  factory :pupil_premium do
    start_year { 2021 }
    total_pupils { Faker::Number.between(from: 1, to: 1000) }
    eligible_pupils { Faker::Number.between(from: 0, to: total_pupils) }

    trait :eligible do
      eligible_pupils { Faker::Number.between(from: (0.4 * total_pupils).ceil, to: total_pupils) }
    end

    trait :not_eligible do
      eligible_pupils { Faker::Number.between(from: 0, to: (0.39 * total_pupils).floor) }
    end
  end
end
