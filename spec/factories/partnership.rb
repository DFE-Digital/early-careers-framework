# frozen_string_literal: true

FactoryBot.define do
  factory :partnership do
    transient do
      create_provider_relationship { true }
    end

    school           { association :school }
    lead_provider    { association :lead_provider }
    delivery_partner { association :delivery_partner }
    cohort           { Cohort.current || create(:cohort, :current) }

    challenge_deadline { rand(-21..21).days.from_now }
    report_id { Random.uuid }

    after(:build) do |partnership, evaluator|
      provider_relationship_attrs = { cohort: partnership.cohort, lead_provider: partnership.lead_provider, delivery_partner: partnership.delivery_partner }
      if evaluator.create_provider_relationship && !ProviderRelationship.where(provider_relationship_attrs).exists?
        create(:provider_relationship, provider_relationship_attrs)
      end
    end
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

  trait :without_provider_relationship do
    create_provider_relationship { false }
  end
end
