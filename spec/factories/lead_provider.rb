# frozen_string_literal: true

FactoryBot.define do
  factory :lead_provider do
    name  { "Lead Provider" }
    cohorts { Cohort.all }
    cpd_lead_provider { create(:cpd_lead_provider) }

    trait :contract do
      before(:create) do |lead_provider|
        create(:call_off_contract, lead_provider:)
      end
    end

    trait :with_delivery_partner do
      before(:create) do |lead_provider|
        create(:provider_relationship, lead_provider:)
      end
    end
  end
end
