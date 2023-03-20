# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_email, class: "Email") do
    tags { [:request_for_details] }
    from { Faker::Internet.email }
    to { Faker::Internet.email }
    delivered_at { 1.year.ago }

    trait(:valid) {}

    after(:build) do |nb|
      Rails.logger.debug("created email for #{nb.to}")
    end
  end
end
