# frozen_string_literal: true

require "rails_helper"

RSpec.describe CallOffContract, type: :model do
  let(:call_off_contract) { create(:call_off_contract) }

  describe "associations" do
    it { is_expected.to have_many(:participant_bands) }

    it "is expected to have band_a with nil as the lowest min value" do
      expect(call_off_contract.band_a.min).to eq(nil)
    end
  end
end
