# frozen_string_literal: true

FactoryBot.define do
  factory :call_off_contract do
    uplift_target { 0.33 }
    uplift_amount { 100 }
    recruitment_target { 2000 }
    set_up_fee { 149_651 }
    lead_provider { build(:lead_provider, cpd_lead_provider: build(:cpd_lead_provider)) }
    raw do
      {
        "uplift_target": 0.33,
        "uplift_amount": 100,
        "recruitment_target": 2000,
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
          "per_participant": 966,
        }.to_json,
      }
    end
    after(:build) do |contract, evaluator|
      contract.lead_provider = evaluator.lead_provider
    end
    after(:create) do |contract|
      create(:participant_band, :band_a, { call_off_contract: contract })
      create(:participant_band, :band_b, { call_off_contract: contract })
      create(:participant_band, :band_c, { call_off_contract: contract })
    end
  end
end
