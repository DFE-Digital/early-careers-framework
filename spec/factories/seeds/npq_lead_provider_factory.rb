# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_npq_lead_provider, class: "NPQLeadProvider") do
    name { Faker::Company.name }

    trait(:with_cpd_lead_provider) { association(:cpd_lead_provider, factory: :seed_cpd_lead_provider) }

    trait(:valid) { with_cpd_lead_provider }

    after(:build) { |npqlp| Rails.logger.debug("seeded npq lead provider #{npqlp.name}") }
  end
end
