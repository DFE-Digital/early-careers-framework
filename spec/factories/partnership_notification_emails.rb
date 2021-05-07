# frozen_string_literal: true

FactoryBot.define do
  factory :partnership_notification_email do
    partnerable { build(:partnership) }
    token { Faker::Alphanumeric.alphanumeric(number: 16) }
    sent_to { Faker::Internet.email }
    notify_id { Faker::Internet.uuid }
    email_type { "school_email" }

    trait :challenged do
      partnerable { build(:partnership, :challenged) }
    end
  end
end
