# frozen_string_literal: true

seed_quantity(:ects_2021_not_completed_induction_partially_declared).times do |i|
  lead_provider = LeadProvider.find_by(name: "Ambition Institute")
  cohort = Cohort.find_by(start_year: 2021)
  school = NewSeeds::Scenarios::Schools::School
    .new
    .build
    .with_partnership_in(cohort:, lead_provider:)
    .chosen_fip_and_partnered_in(cohort:)

  mentor_school = NewSeeds::Scenarios::Schools::School
    .new
    .build
    .with_partnership_in(cohort:, lead_provider:)
    .chosen_fip_and_partnered_in(cohort:)

  ect_builder = NewSeeds::Scenarios::Participants::Ects::Ect
    .new(school_cohort: school.school_cohort, email: "cohort-21-ect-#{i}@email.com")
    .build
    .with_validation_data
    .with_eligibility
    .with_induction_record(induction_programme: school.induction_programme)
    .with_becoming_a_mentor(
      mentor_school_cohort: mentor_school.school_cohort,
      mentor_induction_programme: mentor_school.induction_programme,
    )

  npq_lead_providers = NPQLeadProvider.all
  NewSeeds::Scenarios::NPQ
    .new(
      lead_provider: npq_lead_providers.sample,
      cohort:,
      participant_profile: ect_builder.participant_profile,
      user: ect_builder.user,
    )
    .build
    .accept_application
    .add_declaration
end
