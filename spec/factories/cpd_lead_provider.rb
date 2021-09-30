# frozen_string_literal: true

FactoryBot.define do
  factory :cpd_lead_provider do
    name  { "CPD Lead Provider" }

    trait :with_lead_provider do
      lead_provider
    end
  end
end
