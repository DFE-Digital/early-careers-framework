# frozen_string_literal: true

FactoryBot.define do
  factory :partnership do
    school
    lead_provider
    cohort
  end
end
