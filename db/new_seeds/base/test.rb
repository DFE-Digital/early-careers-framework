lead_provider = LeadProvider.find_by!(name: "Ambition Institute")
cpd_lead_provider = lead_provider.cpd_lead_provider
course_identifier = "ecf-induction"
delivery_partner = FactoryBot.create(:delivery_partner, name: "Test ECT Delivery Partner")
school = NewSeeds::Scenarios::Schools::School.new(name: "Test ECT School", urn: "1234567")
  .build
  .with_an_induction_tutor(full_name: "SIT 1", email: "ect@example.com")
  .school

Cohort.find_each do |cohort|
  ProviderRelationship.create!(delivery_partner:, lead_provider:, cohort:)

  SchoolCohort.create!(school_id: school.id, cohort_id: cohort.id, induction_programme_choice: "full_induction_programme")

  created_partnership = Partnerships::Create.new({
    cohort: cohort.start_year,
    school_id: school.id,
    lead_provider_id: lead_provider.id,
    delivery_partner_id: delivery_partner.id,
  }).call
  raise RuntimeError("Can't create partnership") unless created_partnership
end

# Create participant in 2021 cohort.
participant_identity = FactoryBot.create(:participant_identity)
user = participant_identity.user
school_cohort = SchoolCohort.includes(:cohort).find_by!(school:, cohort: { start_year: 2021 })
cohort = school_cohort.cohort
participant_profile = FactoryBot.create(:ect, :eligible_for_funding, cohort:, school_cohort:, lead_provider:, user:)

# Create declarations against 2021.
paid_declaration = FactoryBot.create(:ect_participant_declaration, :eligible, participant_profile:, state: :paid, course_identifier:, cpd_lead_provider:, cohort:)

# Freeze cohort 2021.
Cohort.find_by(start_year: 2021).update!(payments_frozen_at: Time.zone.now)

# Migrate to 2024 cohort.
original_schedule = participant_profile.schedule
params = {
  cpd_lead_provider:,
  participant_id: participant_profile.user_id,
  course_identifier:,
  schedule_identifier: original_schedule.schedule_identifier,
  cohort: 2024,
  attempt_to_change_cohort_leaving_billable_declarations: true,
}
change_schedule = ChangeSchedule.new(params)
raise RuntimeError("Change schedule invalid") if change_schedule.invalid?

change_schedule.call

# Submit a new declaration for 2021 cohort.
params = {
  cpd_lead_provider:,
  course_identifier:,
  declaration_date: "2024-05-28T13:58:07+01:00",
  declaration_type: "retained-1",
  participant_id: participant_profile.user_id,
  evidence_held: "training-event-attended",
}
record_declaration = RecordDeclaration.new(params)
byebug if record_declaration.invalid?
raise RuntimeError("Record declaration invalid") if record_declaration.invalid?

record_declaration.call

# Clawback paid declaration in 2021 cohort.
VoidParticipantDeclaration.new(paid_declaration.reload).call
