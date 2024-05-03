# frozen_string_literal: true

auto_onboard_to_2024_cohort = false
lead_provider = LeadProvider.find_by!(name: "Ambition Institute")
cpd_lead_provider = lead_provider.cpd_lead_provider
course_identifier = "ecf-mentor"
delivery_partner = FactoryBot.create(:delivery_partner, name: "Test Mentor Delivery Partner")
school = NewSeeds::Scenarios::Schools::School.new(name: "Test Mentor School", urn: "7891234")
  .build
  .with_an_induction_tutor(full_name: "SIT 1", email: "mentor@example.com")
  .school

Cohort.find_each do |cohort|
  # Nathan creates via admin console
  ProviderRelationship.create!(delivery_partner:, lead_provider:, cohort:)

  if cohort.start_year != 2024 || auto_onboard_to_2024_cohort
    SchoolCohort.create!(school_id: school.id, cohort_id: cohort.id, induction_programme_choice: "full_induction_programme")

    created_partnership = Partnerships::Create.new({
      cohort: cohort.start_year,
      school_id: school.id,
      lead_provider_id: lead_provider.id,
      delivery_partner_id: delivery_partner.id,
    }).call
    raise RuntimeError unless created_partnership
  end
end

seed_quantity(:ects_2021_not_completed_induction_partially_declared).times do
  # Create participant in 2021 cohort.
  participant_identity = FactoryBot.create(:participant_identity)
  user = participant_identity.user
  school_cohort = SchoolCohort.includes(:cohort).find_by!(school:, cohort: { start_year: 2021 })
  cohort = school_cohort.cohort
  participant_profile = FactoryBot.create(:mentor, :eligible_for_funding, cohort:, school_cohort:, lead_provider:, user:)

  # Create declarations against 2021.
  state = ParticipantDeclaration.states.values.sample
  FactoryBot.create(:ect_participant_declaration, :eligible, participant_profile:, state:, course_identifier:, cpd_lead_provider:)
end
