# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_privacy_policy, class: "PrivacyPolicy") do
    major_version { 99 }
    sequence(:minor_version) { |n| n }

    trait(:valid) {}
    html { Faker::Lorem.paragraph }

    after(:build) { |pp| Rails.logger.debug("seeded privacy policy #{pp.major_version}.#{pp.minor_version}") }
  end
end
