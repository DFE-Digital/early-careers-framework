# frozen_string_literal: true

lead_provider = LeadProvider.find_by!(name: "Ambition Institute")
cpd_lead_provider = lead_provider.cpd_lead_provider

cohort_2021 = Cohort.find_by!(start_year: 2021)
cohort_2024 = Cohort.find_by!(start_year: 2024)

course_identifier = "ecf-mentor"

seed_quantity(:mentors_2021_not_completed_training_partially_declared).times do
  # Create participant in 2021 cohort.
  participant_identity = FactoryBot.create(:participant_identity)
  user = participant_identity.user
  participant_profile = FactoryBot.create(:mentor, cohort: cohort_2021, lead_provider:, user:)

  # Switch to Mentor schedule (not sure why the factory puts it as ECF in the first place).
  schedule = Finance::Schedule::Mentor.find_by!(cohort: cohort_2021)
  participant_profile.update!(schedule:)
  participant_profile.induction_records.update!(schedule:)

  # Create declarations against 2021.
  state = ParticipantDeclaration.states.values.sample
  FactoryBot.create(:participant_declaration, participant_profile:, state:, course_identifier:, cpd_lead_provider:)

  # Setup 2024 induction programme to allow change schedule.
  school = participant_profile.school
  FactoryBot.create(:school_cohort, :cip, :with_induction_programme, cohort: cohort_2024, lead_provider:, school:)
end
