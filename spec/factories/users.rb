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

    trait :no_privacy_policy_accepted do
      transient do
        privacy_policy_accepted { false }
      end
    end

    trait :induction_coordinator do
      induction_coordinator_profile

      transient do
        privacy_policy_accepted { "0.1" }
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

      after(:create) do |user, evaluator|
        if evaluator.privacy_policy_accepted
          major, minor = evaluator.privacy_policy_accepted.split(".")
          policy = PrivacyPolicy.find_by!(major_version: major, minor_version: minor)
          policy.accept!(user)
        end
      end
    end

    trait :lead_provider do
      lead_provider_profile { build(:lead_provider_profile) }
    end

    trait :early_career_teacher do
      early_career_teacher_profile { build(:early_career_teacher_profile) }
    end
  end
end
