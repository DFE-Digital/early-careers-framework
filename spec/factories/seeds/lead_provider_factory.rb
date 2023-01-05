# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_lead_provider, class: "LeadProvider") do
    name { Faker::Company.name }

    trait(:with_cpd_lead_provider) { association(:cpd_lead_provider, factory: :seed_cpd_lead_provider) }

    trait(:valid) { with_cpd_lead_provider }

    after(:build) { |lp| Rails.logger.debug("seeded lead provider #{lp.name}") }
  end
end
