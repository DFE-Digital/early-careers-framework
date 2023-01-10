# frozen_string_literal: true

FactoryBot.define do
  factory :pupil_premium do
    start_year { build(:cohort, :current).start_year }
    total_pupils { Faker::Number.between(from: 1, to: 1000) }
    eligible_pupils { Faker::Number.between(from: 0, to: total_pupils) }

    trait :uplift do
      pupil_premium_incentive { true }
    end

    trait :sparse do
      sparsity_incentive { true }
    end
  end
end
