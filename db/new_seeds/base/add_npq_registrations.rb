# frozen_string_literal: true

npq_lead_providers = NPQLeadProvider.all

# Create pending NPQ applications
15.times do
  NewSeeds::Scenarios::NPQ
    .new(lead_provider: npq_lead_providers.sample)
    .build
end

# Create accepted NPQ applications with participant profiles
# and a declaration
30.times do
  NewSeeds::Scenarios::NPQ
    .new(lead_provider: npq_lead_providers.sample)
    .build
    .accept_application
    .add_declaration
end

# Create rejected NPQ applications
15.times do
  NewSeeds::Scenarios::NPQ
    .new(lead_provider: npq_lead_providers.sample)
    .build
    .reject_application
end

# Create pending NPQ applications to ASO NPQ course
10.times do
  NewSeeds::Scenarios::NPQ
    .new(
      lead_provider: npq_lead_providers.sample,
      npq_course: NPQCourse.find_by(identifier: "npq-additional-support-offer"),
    )
    .build
end

# Create pending NPQ applications to EHCO NPQ course
10.times do
  NewSeeds::Scenarios::NPQ
    .new(
      lead_provider: npq_lead_providers.sample,
      npq_course: NPQCourse.find_by(identifier: "npq-early-headship-coaching-offer"),
    )
    .build
end
