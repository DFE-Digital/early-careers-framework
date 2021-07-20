# frozen_string_literal: true

FactoryBot.define do
  factory :participation_record do
    early_career_teacher_profile
    cpd_lead_provider
  end
end
