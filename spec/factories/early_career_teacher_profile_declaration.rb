# frozen_string_literal: true

FactoryBot.define do
  factory :early_career_teacher_profile_declaration do
    trait :sparsity_uplift do
      association :early_career_teacher_profile, :sparsity_uplift
    end

    trait :pupil_premium_uplift do
      association :early_career_teacher_profile, :pupil_premium_uplift
    end

    trait :uplift_flags do
      association :early_career_teacher_profile, :uplift_flags
    end
  end
end
