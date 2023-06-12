# frozen_string_literal: true

FactoryBot.define do
  factory :partnership do
    school           { association :school }
    lead_provider    { association :lead_provider }
    delivery_partner { association :delivery_partner }
    cohort           { Cohort.current || create(:cohort, :current) }

    challenge_deadline { rand(-21..21).days.from_now }
    report_id { Random.uuid }
  end

  trait :challenged do
    challenged_at { 2.days.ago }
    challenge_reason { "mistake" }
  end

  trait :pending do
    pending { true }
  end

  trait :in_challenge_window do
    challenge_deadline { rand(1..21).days.from_now }
  end
end
