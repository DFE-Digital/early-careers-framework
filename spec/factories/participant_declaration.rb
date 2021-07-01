# frozen_string_literal: true

FactoryBot.define do
  factory :participant_declaration do
    user
    lead_provider
    declaration_date { Time.zone.now - 1.week }
    declaration_type { "started" }

    trait :sparsity_uplift do
      with_random_profile
      uplift { :sparsity_uplift }
    end

    trait :pupil_premium_uplift do
      with_random_profile
      uplift { :pupil_premium_uplift }
    end

    trait :uplift_flags do
      with_random_profile
      uplift { :uplift_flags }
    end

    trait :only_mentor_profile do
      with_profile_type
      profile_type { :mentor_profile }
    end

    trait :only_ect_profile do
      with_profile_type
      profile_type { :early_career_teacher_profile }
    end

    transient do
      uplift { :sparsity_uplift }
      profile_type { :early_career_teacher_profile }
    end

    trait :with_random_profile do
      after(:create) do |participant_declaration, evaluator|
        create(:profile_declaration,
               participant_declaration: participant_declaration,
               declarable: create(
                 %i[early_career_teacher_profile mentor_profile].sample,
                 evaluator.uplift,
               ))
      end
    end

    trait :with_profile_type do
      after(:create) do |participant_declaration, evaluator|
        create(:profile_declaration,
               participant_declaration: participant_declaration,
               declarable: create(
                 evaluator.profile_type,
                 evaluator.uplift,
               ))
      end
    end
  end
end
