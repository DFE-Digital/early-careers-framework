# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_lead_provider, class: "LeadProvider") do
    name { Faker::Company.name }

    trait(:valid) {}

    after(:build) { |lp| Rails.logger.debug("seeded lead provider #{lp.name}") }
  end
end
