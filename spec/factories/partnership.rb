# frozen_string_literal: true

FactoryBot.define do
  factory :partnership do
    school
    lead_provider
    delivery_partner
    cohort
  end

  trait :challenged do
    challenged_at { 2.days.ago }
    challenge_reason { "mistake" }
  end
end
