# frozen_string_literal: true

npq_lead_providers = NPQLeadProvider.all
[Cohort.previous, Cohort.current, Cohort.next].map do |cohort|
  # Create pending NPQ applications
  seed_quantity(:npq_applications_pending).times do
    NewSeeds::Scenarios::NPQ
      .new(
        lead_provider: npq_lead_providers.sample,
        cohort:,
      )
      .build
  end

  # Create accepted NPQ applications with participant profiles
  # and a declaration
  seed_quantity(:npq_application_with_declarations).times do
    NewSeeds::Scenarios::NPQ
      .new(
        lead_provider: npq_lead_providers.sample,
        cohort:,
      )
      .build
      .accept_application
      .add_declaration
  end

  # Create rejected NPQ applications
  seed_quantity(:npq_applications_rejected).times do
    NewSeeds::Scenarios::NPQ
      .new(
        lead_provider: npq_lead_providers.sample,
        cohort:,
      )
      .build
      .reject_application
  end

  # Create pending NPQ applications to ASO NPQ course
  seed_quantity(:npq_applications_aso).times do
    NewSeeds::Scenarios::NPQ
      .new(
        lead_provider: npq_lead_providers.sample,
        npq_course: NPQCourse.find_by(identifier: "npq-additional-support-offer"),
        cohort:,
      )
      .build
  end

  # Create pending NPQ applications to EHCO NPQ course
  seed_quantity(:npq_applications_ehco).times do
    NewSeeds::Scenarios::NPQ
      .new(
        lead_provider: npq_lead_providers.sample,
        npq_course: NPQCourse.find_by(identifier: "npq-early-headship-coaching-offer"),
        cohort:,
      )
      .build
  end

  # Create NPQLeadership applications with participant profile and declaration
  seed_quantity(:npq_applications_leadership).times do
    NewSeeds::Scenarios::NPQ
      .new(
        lead_provider: npq_lead_providers.sample,
        npq_course: NPQCourse.find_by(identifier: Finance::Schedule::NPQLeadership::IDENTIFIERS.sample),
        cohort:,
      )
      .build
      .accept_application
  end

  # Create NPQSpecialist applications with participant profile and declaration
  seed_quantity(:npq_applications_specialist).times do
    NewSeeds::Scenarios::NPQ
      .new(
        lead_provider: npq_lead_providers.sample,
        npq_course: NPQCourse.find_by(identifier: Finance::Schedule::NPQSpecialist::IDENTIFIERS.sample),
        cohort:,
      )
      .build
      .accept_application
  end

  # Create NPQEhco applications with participant profile and declaration
  seed_quantity(:npq_applications_ehco).times do
    NewSeeds::Scenarios::NPQ
      .new(
        lead_provider: npq_lead_providers.sample,
        npq_course: NPQCourse.find_by(identifier: Finance::Schedule::NPQEhco::IDENTIFIERS.sample),
        cohort:,
      )
      .build
      .accept_application
  end

  # Create edge case NPQ applications
  seed_quantity(:npq_applications_edge_cases).times do
    NewSeeds::Scenarios::NPQ
      .new(
        lead_provider: npq_lead_providers.sample,
        cohort:,
      )
      .build
      .edge_cases
  end
end
