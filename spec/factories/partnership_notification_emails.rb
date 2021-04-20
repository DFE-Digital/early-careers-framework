# frozen_string_literal: true

FactoryBot.define do
  factory :partnership_notification_email do
    partnership
    token { Faker::Alphanumeric.alphanumeric(number: 16) }
    sent_to { Faker::Internet.email }
    notify_id { Faker::Internet.uuid }
    email_type { "school_email" }

    trait :challenged do
      partnership { build(:partnership, challenged_at: 2.days.ago, challenge_reason: "mistake") }
    end
  end
end
