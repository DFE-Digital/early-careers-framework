# frozen_string_literal: true

FactoryBot.define do
  factory :call_off_contract do
    uplift_target { 0.33 }
    uplift_amount { 100 }
    recruitment_target { 6000 }
    revised_target { nil }
    set_up_fee { 149_651 }
    lead_provider { build(:lead_provider, cpd_lead_provider: build(:cpd_lead_provider)) }
    cohort { Cohort.current || create(:cohort, :current) }
    version { "1.0" }
    raw do
      {
        "uplift_target": 0.33,
        "uplift_amount": 100,
        "recruitment_target": 6000,
        "set-up_fee": 149_861,
        "band_a": {
          "max": 2000,
          "per_participant": 995,
        },
        "band_b": {
          "min": 2001,
          "max": 4000,
          "per_participant": 979,
        },
        "band_c": {
          "min": 4001,
          "max": 6000,
          "per_participant": 966,
        },
      }.to_json
    end

    trait :with_monthly_service_fee do
      monthly_service_fee { 123.45 }
    end

    after(:build) do |contract, evaluator|
      contract.lead_provider = evaluator.lead_provider
    end

    transient do
      with_minimal_bands { false }
    end

    trait :with_minimal_bands do
      transient do
        with_minimal_bands { true }
      end

      after(:create) do |contract, _evaluator|
        create(:participant_band, call_off_contract: contract, max: 2, per_participant: 400)
        create(:participant_band, call_off_contract: contract, min: 3, max: 4, per_participant: 300)
        create(:participant_band, call_off_contract: contract, min: 5, max: 6, per_participant: 200)
        create(:participant_band, call_off_contract: contract, min: 7, max: 8, per_participant: 100)
      end
    end

    after(:create) do |contract, evaluator|
      unless evaluator.with_minimal_bands
        create(:participant_band, :band_a, call_off_contract: contract)
        create(:participant_band, :band_b, call_off_contract: contract)
        if contract.revised_target.present?
          create(:participant_band, :band_c_with_additional, max: contract.recruitment_target, call_off_contract: contract)
          create(:participant_band, :additional, min: contract.recruitment_target + 1, max: contract.revised_target, call_off_contract: contract)
        else
          create(:participant_band, :band_c, max: contract.recruitment_target, call_off_contract: contract)
        end
      end
    end
  end
end
