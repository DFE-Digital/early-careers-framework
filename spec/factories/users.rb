# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    sequence(:full_name) { |n| "John Doe #{n}" }
    login_token { Faker::Alphanumeric.alpha(number: 10) }
    login_token_valid_until { 12.hours.from_now }

    trait :admin do
      admin_profile
    end

    trait :super_user do
      admin_profile { create(:admin_profile, :super_user) }
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

    trait :archived do
      archived_email { Faker::Internet.unique.email }
    end

    trait :lead_provider do
      lead_provider_profile
    end

    trait :teacher do
      teacher_profile
    end

    trait :early_career_teacher do
      teacher_profile { create(:teacher_profile, early_career_teacher_profile: create(:ect_participant_profile)) }
    end

    trait :mentor do
      teacher_profile { create(:teacher_profile, mentor_profile: create(:mentor_participant_profile)) }
    end

    trait :finance do
      finance_profile
    end

    trait :delivery_partner do
      after(:create) do |u|
        create(:delivery_partner_profile, user: u)
      end
    end

    trait :appropriate_body do
      after(:create) do |u|
        create(:appropriate_body_profile, user: u)
      end
    end

    trait :random_name do
      full_name { Faker::Name.name }
    end

    trait :with_get_an_identity_id do
      get_an_identity_id { SecureRandom.uuid }
    end
  end
end
