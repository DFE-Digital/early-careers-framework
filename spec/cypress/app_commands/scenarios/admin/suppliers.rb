# frozen_string_literal: true

delivery_partner = FactoryBot.create(:delivery_partner, name: "Delivery Partner 1")
cohort = FactoryBot.create(:cohort, start_year: 2021)
lead_provider = FactoryBot.create(:lead_provider, name: "Lead Provider 1", cohorts: [cohort])
ProviderRelationship.create!(delivery_partner: delivery_partner, lead_provider: lead_provider, cohort: cohort)

lead_provider_2 = FactoryBot.create(:lead_provider, cohorts: [cohort])
ProviderRelationship.create!(delivery_partner: delivery_partner, lead_provider: lead_provider_2, cohort: cohort)

FactoryBot.create(:user, :lead_provider, full_name: "John Wick", email: "john-wick@example.com")
