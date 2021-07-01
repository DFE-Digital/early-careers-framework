# frozen_string_literal: true

FactoryBot.define do
  factory :profile_declaration do
    participant_declaration
    lead_provider { participant_declaration.lead_provider }
  end
end
