# frozen_string_literal: true

require "rails_helper"

RSpec.describe CallOffContract, type: :model do
  let(:call_off_contract) { create(:call_off_contract) }

  describe "associations" do
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to have_many(:participant_bands) }

    it "is expected to have band_a with the lowest minimum value" do
      expect(call_off_contract.band_a.min.to_i).to eq(0)
    end

    it "is expected to have a total contract value" do
      expect(call_off_contract.total_contract_value).to eql(5_880_000)
    end
  end

  describe "#uplift_cap" do
    # the following makes the maths much easier
    # as there is no longer half uplifts
    # especially when dealing with clawbacks
    it "is rounded up to nearest uplift_amount" do
      allow(call_off_contract).to receive(:total_contract_value).and_return(3_000)

      expect(call_off_contract.uplift_cap).to eq(200)
    end
  end
end
