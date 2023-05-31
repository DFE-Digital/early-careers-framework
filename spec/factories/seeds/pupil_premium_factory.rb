# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_pupil_premium, class: "PupilPremium") do
    start_year { build(:cohort, :current).start_year }
    pupil_premium_incentive { false }
    sparsity_incentive { false }

    trait :with_school do
      association(:school, factory: %i[seed_school valid])
    end

    trait(:with_pupil_premiums) do
      pupil_premium_incentive { true }
    end

    trait(:with_sparsity) do
      sparsity_incentive { true }
    end

    trait(:with_uplifts) do
      with_pupil_premiums
      with_sparsity
    end

    trait(:valid) do
      with_school
    end

    after(:build) { |pp| Rails.logger.debug("seeded pupil_premium for #{pp.start_year}") }
  end
end
