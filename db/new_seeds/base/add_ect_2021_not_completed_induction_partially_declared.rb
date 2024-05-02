# frozen_string_literal: true

lead_provider = LeadProvider.find_by!(name: "Ambition Institute")
cpd_lead_provider = lead_provider.cpd_lead_provider

cohort_2021 = Cohort.find_by!(start_year: 2021)
Cohort.find_by!(start_year: 2024)

course_identifier = "ecf-induction"

delivery_partner = FactoryBot.create(:delivery_partner, name: "Test ECT Delivery Partner")
school = FactoryBot.create(:school, name: "Test ECT School")

ProviderRelationship.create!(delivery_partner:, lead_provider:, cohort: cohort_2021)
created_partnership = Partnerships::Create.new({
  cohort: 2021,
  school_id: school.id,
  lead_provider_id: lead_provider.id,
  delivery_partner_id: delivery_partner.id,
}).call
raise RuntimeError unless created_partnership

# Commenting out so that we can do this as a provider would.
# ProviderRelationship.create!(delivery_partner:, lead_provider:, cohort: cohort_2024)
# created_partnership = Partnerships::Create.new({
#   cohort: 2024,
#   school_id: school.id,
#   lead_provider_id: lead_provider.id,
#   delivery_partner_id: delivery_partner.id,
# }).call
# raise RuntimeError unless created_partnership

seed_quantity(:ects_2021_not_completed_induction_partially_declared).times do
  # Create participant in 2021 cohort.
  participant_identity = FactoryBot.create(:participant_identity)
  user = participant_identity.user
  school_cohort_2021 = SchoolCohort.find_by!(school:, cohort: cohort_2021)
  participant_profile = FactoryBot.create(:ect, cohort: cohort_2021, school_cohort: school_cohort_2021, lead_provider:, user:)

  # Create declarations against 2021.
  state = ParticipantDeclaration.states.values.sample
  FactoryBot.create(:participant_declaration, participant_profile:, state:, course_identifier:, cpd_lead_provider:)
end
