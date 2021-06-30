# frozen_string_literal: true

FactoryBot.define do
  factory :participant_declaration do
    user
    lead_provider
    declaration_date { Time.zone.now - 1.week }
    declaration_type { "started" }

    trait :sparsity_uplift do
      with_random_profile_declaration
      uplift { :sparsity_uplift }
    end

    trait :pupil_premium_uplift do
      with_random_profile_declaration
      uplift { :pupil_premium_uplift }
    end

    trait :uplift_flags do
      with_random_profile_declaration
      uplift { :uplift_flags }
    end

    trait :only_mentor_profile_declarations do
      with_profile_type_declaration
      profile_type { :mentor_profile_declaration }
    end

    trait :only_ect_profile_declarations do
      with_profile_type_declaration
      profile_type { :early_career_teacher_profile_declaration }
    end

    transient do
      uplift { :sparsity_uplift }
      profile_type { :early_career_teacher_profile_declaration }
    end

    trait :with_random_profile_declaration do
      after(:create) do |participant_declaration, evaluator|
        create(:profile_declaration,
               participant_declaration: participant_declaration,
               declarable: create(
                 %i[early_career_teacher_profile_declaration mentor_profile_declaration].sample,
                 evaluator.uplift,
               ))
      end
    end

    trait :with_profile_type_declaration do
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
