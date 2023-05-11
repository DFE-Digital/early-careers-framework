# frozen_string_literal: true

FactoryBot.define do
  factory :pupil_premium do
    start_year { build(:cohort, :current).start_year }

    trait :uplift do
      pupil_premium_incentive { true }
    end

    trait :sparse do
      sparsity_incentive { true }
    end
  end
end
