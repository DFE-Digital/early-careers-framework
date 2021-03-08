# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    full_name { Faker::Name.name }
    login_token { Faker::Alphanumeric.alpha(number: 10) }
    confirmed_at { 1.hour.ago }
    login_token_valid_until { 1.hour.from_now }

    trait :admin do
      admin_profile { build(:admin_profile) }
    end

    trait :induction_coordinator do
      induction_coordinator_profile { build(:induction_coordinator_profile) }
    end

    trait :lead_provider do
      lead_provider_profile { build(:lead_provider_profile) }
    end

    trait :early_career_teacher do
      early_career_teacher_profile { build(:early_career_teacher_profile) }
    end
  end
end
