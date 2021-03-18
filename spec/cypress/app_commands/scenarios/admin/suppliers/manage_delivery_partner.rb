# frozen_string_literal: true

delivery_partner = FactoryBot.create(:delivery_partner, name: "Delivery Partner 1")
cohort = FactoryBot.create(:cohort)
lead_provider = FactoryBot.create(:lead_provider, id: "e38e8825-4430-4da0-ac54-6e42dea5c360", name: "Lead Provider 1", cohorts: [cohort])
ProviderRelationship.create!(delivery_partner: delivery_partner, lead_provider: lead_provider, cohort: cohort)

lead_provider_2 = FactoryBot.create(:lead_provider, cohorts: [cohort])
ProviderRelationship.create!(delivery_partner: delivery_partner, lead_provider: lead_provider_2, cohort: cohort)
