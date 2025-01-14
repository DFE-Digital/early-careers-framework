# frozen_string_literal: true

FactoryBot.define do
  factory :mentor_call_off_contract do
    lead_provider { build(:lead_provider, cpd_lead_provider: build(:cpd_lead_provider)) }
    cohort { Cohort.current || create(:cohort, :current) }

    recruitment_target { 6000 }
    payment_per_participant { 1000.0 }
    version { "0.0.1" }
  end
end
