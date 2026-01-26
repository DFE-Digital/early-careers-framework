# frozen_string_literal: true

require "rails_helper"

RSpec.describe CallOffContract, type: :model do
  let(:call_off_contract) { create(:call_off_contract) }

  describe "associations" do
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to belong_to(:lead_provider) }
    it { is_expected.to have_many(:participant_bands) }
  end

  describe "scopes" do
    describe ".not_flagged_as_unused" do
      let!(:call_off_contract) { create(:call_off_contract) }

      before { create(:call_off_contract, :unused) }

      subject { described_class.not_flagged_as_unused }

      it { is_expected.to contain_exactly(call_off_contract) }
    end
  end

  describe "#include_uplift_fees?" do
    context "when `uplift_amount` is present" do
      it "returns true" do
        expect(call_off_contract.include_uplift_fees?).to be_truthy
      end
    end

    context "when `uplift_amount` is not present" do
      before { call_off_contract.uplift_amount = nil }

      it "returns false" do
        expect(call_off_contract.include_uplift_fees?).to be_falsey
      end
    end
  end
end
