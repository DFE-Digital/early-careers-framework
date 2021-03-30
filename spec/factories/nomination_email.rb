# frozen_string_literal: true

FactoryBot.define do
  factory :nomination_email do
    token { "foo-bar-baz" }
    sent_to { "John-Doe@example.com" }
    sent_at { Time.zone.now }
    school { build(:school, name: "Nominated School", primary_contact_email: "primary-contact-email@example.com") }

    trait :expired_nomination_email do
      sent_at { 1.year.ago }
    end

    trait :already_nominated_induction_tutor do
      after(:build) do |nomination_email|
        build(:user, :induction_coordinator) do |user|
          user.induction_coordinator_profile.schools << nomination_email.school
        end
      end
    end

    trait :email_address_already_used_for_another_school do
      after(:build) do
        build(:user, :induction_coordinator) do |user|
          school = create(:school, name: "Another Registered School")
          user.induction_coordinator_profile.schools << school
        end
      end
    end
  end
end
