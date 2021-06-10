# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    full_name { Faker::Name.name }
    login_token { Faker::Alphanumeric.alpha(number: 10) }
    login_token_valid_until { 1.hour.from_now }

    trait :admin do
      admin_profile { build(:admin_profile) }
    end

    trait :induction_coordinator do
      induction_coordinator_profile

      transient do
        schools { induction_coordinator_profile.schools }
        school_ids {}
      end

      after(:build) do |user, evaluator|
        if evaluator.school_ids.present?
          user.induction_coordinator_profile.school_ids = evaluator.school_ids
        else
          user.induction_coordinator_profile.schools = evaluator.schools
        end
      end
    end

    trait :lead_provider do
      lead_provider_profile { build(:lead_provider_profile) }
    end

    trait :early_career_teacher do
      early_career_teacher_profile { build(:early_career_teacher_profile) }
      transient do
        mentor {}
        school {}
        cohort {}
      end

      after(:build) do |user, evaluator|
        if evaluator.mentor.present?
          user.early_career_teacher_profile.mentor_profile = evaluator.mentor.mentor_profile
        end
        if evaluator.school.present?
          user.early_career_teacher_profile.school = evaluator.school
        end
        if evaluator.cohort.present?
          user.early_career_teacher_profile.cohort = evaluator.cohort
        end
      end
    end

    trait :mentor do
      mentor_profile { build(:mentor_profile) }

      transient do
        school {}
        cohort {}
      end

      after(:build) do |user, evaluator|
        if evaluator.school.present?
          user.mentor_profile.school = evaluator.school
        end
        if evaluator.cohort.present?
          user.mentor_profile.cohort = evaluator.cohort
        end
      end
    end
  end
end
