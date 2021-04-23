# frozen_string_literal: true

FactoryBot.define do
  factory :partnership do
    school
    lead_provider
    delivery_partner
    cohort
  end
end
