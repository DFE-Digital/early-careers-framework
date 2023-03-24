# frozen_string_literal: true

npq_lead_providers = NPQLeadProvider.all

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

# Create edge case NPQ applications
25.times do
  NewSeeds::Scenarios::NPQ
    .new(lead_provider: npq_lead_providers.sample)
    .build
    .edge_cases
end
