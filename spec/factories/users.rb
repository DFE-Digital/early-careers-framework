# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    full_name { Faker::Name.name }
    login_token { Faker::Alphanumeric.alpha(number: 10) }
    login_token_valid_until { 1.hour.from_now }

    trait :admin do
      admin_profile
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
      lead_provider_profile
    end

    trait :teacher do
      teacher_profile
    end

    trait :early_career_teacher do
      teacher_profile { create(:teacher_profile, early_career_teacher_profile: create(:early_career_teacher_profile)) }
    end

    trait :mentor do
      teacher_profile { create(:teacher_profile, mentor_profile: create(:mentor_profile)) }
    end

    trait :finance do
      finance_profile
    end
  end
end
