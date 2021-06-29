# frozen_string_literal: true

FactoryBot.define do
  factory :participant_declaration do
    early_career_teacher_profile
    lead_provider
    declaration_date { Time.zone.now - 1.week }
    declaration_type { "started" }

    trait :sparsity_uplift do
      with_profile
      association :early_career_teacher_profile, factory: %i[participant_profile ect sparsity_uplift]
    end

    trait :uplift_flags do
      with_profile
      association :early_career_teacher_profile, factory: %i[participant_profile ect uplift_flags]
    end

    trait :pupil_premium_uplift do
      with_profile
      association :early_career_teacher_profile, factory: %i[participant_profile ect pupil_premium_uplift]
    end

    trait :with_profile do
      after(:create) do |participant_declaration, evaluator|
        create(:participant_declaration,
               early_career_teacher_profile: participant_declaration.early_career_teacher_profile,
               lead_provider: evaluator.lead_provider)
      end
    end
  end
end
