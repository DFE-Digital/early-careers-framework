# frozen_string_literal: true

FactoryBot.define do
  factory :lead_provider do
    name  { "Lead Provider" }
    cohorts { Cohort.all }
    cpd_lead_provider

    trait :contract do
      before(:create) do |lead_provider|
        create(:call_off_contract, lead_provider: lead_provider)
      end
    end
  end
end
