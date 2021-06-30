# frozen_string_literal: true

FactoryBot.define do
  factory :mentor_profile_declaration do
    mentor_profile

    trait :sparsity_uplift do
      association :mentor_profile, :sparsity_uplift
    end

    trait :pupil_premium_uplift do
      association :mentor_profile, :pupil_premium_uplift
    end

    trait :uplift_flags do
      association :mentor_profile, :uplift_flags
    end
  end
end
