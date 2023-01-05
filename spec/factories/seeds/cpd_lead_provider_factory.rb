# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_cpd_lead_provider, class: "CpdLeadProvider") do
    name { Faker::Company.name }

    trait(:valid) {}

    after(:build) { |cpdlp| Rails.logger.debug("seeded cpd lead provider #{cpdlp.name}") }
  end
end
