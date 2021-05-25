# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantBand, type: :model do
  let(:call_off_contract) { create(:call_off_contract) }
  let(:band_a) { create(:participant_band, :band_a, call_off_contract: call_off_contract) }
  let(:band_b) { create(:participant_band, :band_b, call_off_contract: call_off_contract) }
  let(:band_c) { create(:participant_band, :band_c, call_off_contract: call_off_contract) }

  describe "associations" do
    it { is_expected.to belong_to(:call_off_contract) }
  end

  describe "ranges" do
    it {
      expect(band_a.number_in_range(100)).to eq(100)
      expect(band_b.number_in_range(100)).to eq(0)
      expect(band_c.number_in_range(100)).to eq(0)
      expect(band_a.number_in_range(2100)).to eq(2000)
      expect(band_b.number_in_range(2100)).to eq(100)
      expect(band_c.number_in_range(2100)).to eq(0)
      expect(band_a.number_in_range(10_000)).to eq(2000)
      expect(band_b.number_in_range(10_000)).to eq(2000)
      expect(band_c.number_in_range(10_000)).to eq(6000)
    }
  end
end
