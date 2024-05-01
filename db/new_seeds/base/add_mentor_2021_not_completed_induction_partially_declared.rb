# frozen_string_literal: true

seed_quantity(:mentors_2021_not_completed_training_partially_declared).times do |i|
  lead_provider = LeadProvider.find_by(name: "Ambition Institute")
  cohort = Cohort.find_by(start_year: 2021)
  edt = CoreInductionProgramme.find_by!(name: "Education Development Trust")

  mentor_school = NewSeeds::Scenarios::Schools::School
    .new
    .build
    .with_partnership_in(cohort:, lead_provider:)
    .chosen_fip_and_partnered_in(cohort:)

  induction_programme = NewSeeds::Scenarios::InductionProgrammes::Cip
    .new(school_cohort: mentor_school.school_cohort)
    .build
    .with_core_induction_programme(core_induction_programme: edt)
    .induction_programme

  mentor_builder = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
    .new(school_cohort: mentor_school.school_cohort, email: "cohort-21-mentor-#{i}@email.com")
    .build(schedule: Finance::Schedule::ECF.default_for(cohort:))
    .with_validation_data
    .with_eligibility
    .with_induction_record(induction_programme:)

  npq_lead_providers = NPQLeadProvider.all
  NewSeeds::Scenarios::NPQ
    .new(
      lead_provider: npq_lead_providers.sample,
      cohort:,
      participant_profile: mentor_builder.participant_profile,
      user: mentor_builder.user,
    )
    .build
    .accept_application
    .add_declaration
end
