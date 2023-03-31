# frozen_string_literal: true

npq_lead_providers = NPQLeadProvider.all
cohort_2022 = Cohort.find_by(start_year: 2022)
cohort_2023 = Cohort.find_by(start_year: 2023)

# Create pending NPQ applications
seed_quantity(:npq_applications_pending).times do
  NewSeeds::Scenarios::NPQ
    .new(lead_provider: npq_lead_providers.sample)
    .build
end

# Create accepted NPQ applications with participant profiles
# and a declaration
seed_quantity(:npq_application_with_declarations).times do
  NewSeeds::Scenarios::NPQ
    .new(lead_provider: npq_lead_providers.sample)
    .build
    .accept_application
    .add_declaration
    .add_statement_line_items
end

# Create rejected NPQ applications
seed_quantity(:npq_applications_rejected).times do
  NewSeeds::Scenarios::NPQ
    .new(lead_provider: npq_lead_providers.sample)
    .build
    .reject_application
end

# Create pending NPQ applications to ASO NPQ course
seed_quantity(:npq_applications_pending_aso).times do
  NewSeeds::Scenarios::NPQ
    .new(
      lead_provider: npq_lead_providers.sample,
      npq_course: NPQCourse.find_by(identifier: "npq-additional-support-offer"),
    )
    .build
end

# Create pending NPQ applications to EHCO NPQ course
seed_quantity(:npq_applications_pending_ehco).times do
  NewSeeds::Scenarios::NPQ
    .new(
      lead_provider: npq_lead_providers.sample,
      npq_course: NPQCourse.find_by(identifier: "npq-early-headship-coaching-offer"),
    )
    .build
end

# Create NPQLeadership applications with participant profile and declaration for cohort 2022
seed_quantity(:npq_applications_eligible_for_transfer).times do
  NewSeeds::Scenarios::NPQ
    .new(
      lead_provider: npq_lead_providers.sample,
      npq_course: NPQCourse.find_by(identifier: Finance::Schedule::NPQLeadership::IDENTIFIERS.sample),
      cohort: cohort_2022,
    )
    .build
    .accept_application
    .add_declaration
    .add_statement_line_items
end

# Create NPQSpecialist applications with participant profile and declaration for cohort 2022
seed_quantity(:npq_applications_eligible_for_transfer).times do
  NewSeeds::Scenarios::NPQ
    .new(
      lead_provider: npq_lead_providers.sample,
      npq_course: NPQCourse.find_by(identifier: Finance::Schedule::NPQSpecialist::IDENTIFIERS.sample),
      cohort: cohort_2022,
    )
    .build
    .accept_application
    .add_declaration
    .add_statement_line_items
end

# Create NPQEhco applications with participant profile and declaration for cohort 2022
seed_quantity(:npq_applications_eligible_for_transfer).times do
  NewSeeds::Scenarios::NPQ
    .new(
      lead_provider: npq_lead_providers.sample,
      npq_course: NPQCourse.find_by(identifier: Finance::Schedule::NPQEhco::IDENTIFIERS.sample),
      cohort: cohort_2022,
    )
    .build
    .accept_application
    .add_declaration
    .add_statement_line_items
end

# Create NPQLeadership applications with participant profile and declaration for cohort 2023
seed_quantity(:npq_applications_eligible_for_transfer).times do
  NewSeeds::Scenarios::NPQ
    .new(
      lead_provider: npq_lead_providers.sample,
      npq_course: NPQCourse.find_by(identifier: Finance::Schedule::NPQLeadership::IDENTIFIERS.sample),
      cohort: cohort_2023,
    )
    .build
    .accept_application
    .add_declaration
    .add_statement_line_items
end

# Create NPQSpecialist applications with participant profile and declaration for cohort 2023
seed_quantity(:npq_applications_eligible_for_transfer).times do
  NewSeeds::Scenarios::NPQ
    .new(
      lead_provider: npq_lead_providers.sample,
      npq_course: NPQCourse.find_by(identifier: Finance::Schedule::NPQSpecialist::IDENTIFIERS.sample),
      cohort: cohort_2023,
    )
    .build
    .accept_application
    .add_declaration
    .add_statement_line_items
end

# Create NPQEhco applications with participant profile and declaration for cohort 2023
seed_quantity(:npq_applications_eligible_for_transfer).times do
  NewSeeds::Scenarios::NPQ
    .new(
      lead_provider: npq_lead_providers.sample,
      npq_course: NPQCourse.find_by(identifier: Finance::Schedule::NPQEhco::IDENTIFIERS.sample),
      cohort: cohort_2023,
    )
    .build
    .accept_application
    .add_declaration
    .add_statement_line_items
end

# Create edge case NPQ applications
25.times do
  NewSeeds::Scenarios::NPQ
    .new(lead_provider: npq_lead_providers.sample)
    .build
    .edge_cases
end
