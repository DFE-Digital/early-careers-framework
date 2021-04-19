# frozen_string_literal: true

FactoryBot.define do
  factory :nomination_email do
    token { Faker::Alphanumeric.alphanumeric(number: 16) }
    sent_to { "John-Doe@example.com" }
    sent_at { Time.zone.now }
    school { build(:school, urn: "0922081", name: "Nominated School", primary_contact_email: "primary-contact-email@example.com", address_line1: "50 Olivia Drive", postcode: "CV37 9HE") }
    notify_id { Faker::Internet.uuid }

    trait :expired_nomination_email do
      sent_at { 22.days.ago }
      school { build(:school, :with_local_authority, name: "Nominated School", primary_contact_email: "primary-contact-email@example.com") }
    end

    trait :nearly_expired_nomination_email do
      sent_at { 20.days.ago }
      school { build(:school, :with_local_authority, name: "Nominated School", primary_contact_email: "primary-contact-email@example.com") }
    end

    trait :already_nominated_induction_tutor do
      after(:build) do |nomination_email|
        create(:user, :induction_coordinator, schools: [nomination_email.school])
      end
    end

    trait :email_address_already_used_for_another_school do
      after(:build) do
        create(:school, name: "Another Registered School") do |school|
          create(:user, :induction_coordinator, email: "john-wick@example.com", schools: [school])
        end
      end
    end
  end
end
