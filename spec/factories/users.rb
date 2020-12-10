# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    login_token { Faker::Alphanumeric.alpha(number: 10) }
    confirmed_at { 1.hour.ago }
    login_token_valid_until { 1.hour.from_now }
  end
end
