# frozen_string_literal: true

FactoryBot.define do
  factory :partnership do
    school
    cohort
    lead_provider
  end
end
