# frozen_string_literal: true

FactoryBot.define do
  factory :early_career_teacher_profile, class: ParticipantProfile::ECT do
    user
    school_cohort
    schedule

    trait :sparsity_uplift do
      sparsity_uplift { true }
    end

    trait :pupil_premium_uplift do
      pupil_premium_uplift { true }
    end

    trait :uplift_flags do
      sparsity_uplift
      pupil_premium_uplift
    end
  end
end
