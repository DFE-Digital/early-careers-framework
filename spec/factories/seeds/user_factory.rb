# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_user, class: "User") do
    email { Faker::Internet.unique.safe_email }
    full_name { Faker::Name.name }

    trait :with_login_topen do
      login_token { Faker::Alphanumeric.alpha(number: 10) }
      login_token_valid_until { 12.hours.from_now }
    end
  end
end
