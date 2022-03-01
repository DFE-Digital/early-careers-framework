# frozen_string_literal: true

FactoryBot.define do
  factory :identity do
    # user
    email { Faker::Internet.unique.safe_email }
    external_identifier { SecureRandom.uuid }
    origin { "ecf" }

    login_token { Faker::Alphanumeric.alpha(number: 10) }
    login_token_valid_until { 1.hour.from_now }

    trait :npq_origin do
      origin { "npq" }
    end
  end
end
