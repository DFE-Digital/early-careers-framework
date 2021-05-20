# frozen_string_literal: true

profile = LeadProviderProfile.order(:created_at).last
lead_provider = profile.lead_provider
schools = [
  FactoryBot.create(:school, name: "Big School", urn: 900_001),
  FactoryBot.create(:school, name: "Middle School", urn: 900_002),
  FactoryBot.create(:school, name: "Small School", urn: 900_003),
]
delivery_partner = FactoryBot.create(:delivery_partner, name: "Ace Delivery Partner")

schools.each do |school|
  FactoryBot.create(:partnership, school: school, lead_provider: lead_provider, delivery_partner: delivery_partner, cohort: Cohort.find_by(start_year: 2021))
end
