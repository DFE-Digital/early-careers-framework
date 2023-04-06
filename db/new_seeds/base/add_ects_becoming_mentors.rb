# frozen_string_literal: true

@cohorts = [Cohort.previous, Cohort.current]
# select providers with API tokens for API testing
@lead_providers = LeadProvider.where(name: ["Ambition Institute", "Best Practice Network", "Capita", "Education Development Trust"])

seed_quantity(:ects_becoming_mentors).times do
  lead_provider = @lead_providers.sample
  cohort = @cohorts.sample
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

  NewSeeds::Scenarios::Participants::Ects::Ect
    .new(school_cohort: school.school_cohort)
    .build
    .with_validation_data
    .with_eligibility
    .with_induction_record(induction_programme: school.induction_programme)
    .with_becoming_a_mentor(
      mentor_school_cohort: mentor_school.school_cohort,
      mentor_induction_programme: mentor_school.induction_programme,
    )
end
