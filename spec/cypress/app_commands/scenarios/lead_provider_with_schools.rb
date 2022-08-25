# frozen_string_literal: true

profile = LeadProviderProfile.order(:created_at).last
lead_provider = profile.lead_provider
schools = [
  FactoryBot.create(:school, :pupil_premium_uplift, name: "Big School", urn: 900_001),
  FactoryBot.create(:school, :sparsity_uplift, name: "Middle School", urn: 900_002),
  FactoryBot.create(:school, :pupil_premium_and_sparsity_uplift, name: "Small School", urn: 900_003),
]
delivery_partner = FactoryBot.create(:delivery_partner, name: "Ace Delivery Partner")

schools.each_with_index do |school, index|
  FactoryBot.create(:partnership, school:, lead_provider:, delivery_partner:, cohort: Cohort.find_by(start_year: 2021))
  FactoryBot.create(:user, :induction_coordinator, schools: [schools[index]], email: "induction.tutor_#{index + 1}@example.com")
end
