# frozen_string_literal: true

FactoryBot.define do
  factory :participant_declaration do
    early_career_teacher_profile
    lead_provider
    declaration_date { Time.zone.now - 1.week }
    declaration_type { "Start" }
  end
end
