# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_cpd_lead_provider, class: "CpdLeadProvider") do
    name { NewSeeds::Scenarios::LeadProviders::LeadProvider::ALL_PROVIDERS.sample }

    initialize_with do
      CpdLeadProvider.find_or_create_by(name:)
    end

    trait(:valid) {}

    after(:build) { |cpdlp| Rails.logger.debug("seeded cpd lead provider #{cpdlp.name}") }
  end
end
