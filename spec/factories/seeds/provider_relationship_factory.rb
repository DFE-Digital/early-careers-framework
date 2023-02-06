# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_provider_relationship, class: "ProviderRelationship") do
    trait(:with_cohort) do
      association(:cohort, factory: :seed_cohort)
    end

    trait(:with_cohort_2022) do
      cohort { Cohort.find_or_create_by!(start_year: 2022) }
    end

    trait(:with_lead_provider) do
      association(:lead_provider, factory: :seed_lead_provider)
    end

    trait(:with_delivery_partner) do
      association(:delivery_partner, factory: :seed_delivery_partner)
    end

    trait(:valid) do
      with_delivery_partner
      with_lead_provider
      with_cohort_2022
    end

    after(:build) do |pr|
      if pr.cohort.present? && pr.lead_provider.present? && pr.delivery_partner.present?
        Rails.logger.debug("seeded provider relationships between #{pr.lead_provider.name} and #{pr.delivery_partner.name} for #{pr.cohort.start_year}")
      else
        Rails.logger.debug("seeded incomplete provider relationship")
      end
    end
  end
end
