# frozen_string_literal: true

npq_lead_providers = NPQLeadProvider.all

20.times do
  NewSeeds::Scenarios::NPQ
    .new(lead_provider: npq_lead_providers.sample)
    .build
    .add_application
    .add_declaration
end
