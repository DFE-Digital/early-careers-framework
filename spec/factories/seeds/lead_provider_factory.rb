# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_lead_provider, class: "LeadProvider") do
    name { LeadProvider::ALL_PROVIDERS.sample }

    initialize_with do
      LeadProvider.find_or_create_by(name:)
    end

    trait(:with_cpd_lead_provider) { association(:cpd_lead_provider, factory: :seed_cpd_lead_provider, name: :name) }

    trait(:valid) { with_cpd_lead_provider }

    after(:build) { |lp| Rails.logger.debug("seeded lead provider #{lp.name}") }
  end
end
