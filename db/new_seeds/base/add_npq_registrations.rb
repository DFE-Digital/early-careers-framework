# frozen_string_literal: true

npq_lead_providers = NPQLeadProvider.all

# Create accepted NPQ applications
10.times do
  NewSeeds::Scenarios::NPQ
    .new(lead_provider: npq_lead_providers.sample)
    .build
    .accept_application
    .add_declaration
end

# Create rejected NPQ applications
5.times do
  NewSeeds::Scenarios::NPQ
    .new(lead_provider: npq_lead_providers.sample)
    .build
    .reject_application
end
