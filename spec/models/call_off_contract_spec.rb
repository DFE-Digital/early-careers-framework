# frozen_string_literal: true

require "rails_helper"

RSpec.describe CallOffContract, type: :model do
  let(:call_off_contract) { create(:call_off_contract) }
  let(:total_contract_value) { call_off_contract.recruitment_target * call_off_contract.band_a.per_participant }

  describe "associations" do
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to have_many(:participant_bands) }

    it "is expected to have band_a with the lowest minimum value" do
      expect(call_off_contract.band_a.min.to_i).to eq(0)
    end

    it "is expected to have a total contract value" do
      expect(call_off_contract.total_contract_value).to eq(total_contract_value) # recruitment_target * per_participant
    end

    it "is expected to have an uplift cap of 5% of the total contract value" do
      expect(call_off_contract.uplift_cap).to eq(total_contract_value * 0.05)
    end
  end
end
