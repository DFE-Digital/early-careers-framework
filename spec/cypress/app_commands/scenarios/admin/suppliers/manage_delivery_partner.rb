# frozen_string_literal: true

delivery_partner = FactoryBot.create(:delivery_partner)
cohort = FactoryBot.create(:cohort)
lead_provider = FactoryBot.create(:lead_provider, cohorts: [cohort])
ProviderRelationship.create!(delivery_partner: delivery_partner, lead_provider: lead_provider, cohort: cohort)
