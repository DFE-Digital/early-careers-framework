# frozen_string_literal: true

FactoryBot.define do
  factory :participant_declaration do
    user
    lead_provider
    declaration_date { Time.zone.now - 1.week }
    declaration_type { "started" }
  end
end
