# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantBand, type: :model do
  context "without revision of recruitment target" do
    let(:call_off_contract) { create(:call_off_contract) }

    %i[band_c band_a band_b].each do |band|
      create(:participant_band, band, call_off_contract: call_off_contract)
    end

    describe "associations" do
      it { is_expected.to belong_to(:call_off_contract) }
    end

    describe "ranges" do
      it {
        expect(band_a.number_of_participants_in_this_band(100)).to eq(100)
        expect(band_b.number_of_participants_in_this_band(100)).to eq(0)
        expect(band_c.number_of_participants_in_this_band(100)).to eq(0)
        expect(band_a.number_of_participants_in_this_band(2000)).to eq(2000)
        expect(band_b.number_of_participants_in_this_band(2000)).to eq(0)
        expect(band_c.number_of_participants_in_this_band(2000)).to eq(0)
        expect(band_a.number_of_participants_in_this_band(2001)).to eq(2000)
        expect(band_b.number_of_participants_in_this_band(2001)).to eq(1)
        expect(band_c.number_of_participants_in_this_band(2001)).to eq(0)
        expect(band_a.number_of_participants_in_this_band(10_000)).to eq(2000)
        expect(band_b.number_of_participants_in_this_band(10_000)).to eq(2000)
        expect(band_c.number_of_participants_in_this_band(10_000)).to eq(6000)
      }
    end

  end

  context "with revised recruitment target" do
    let(:call_off_contract) { create(:call_off_contract) }

    %i[band_b additional band_a band_c_with_additional].each do |band|
      create(:participant_band, band, call_off_contract: call_off_contract)
    end

    describe "associations" do
      it { is_expected.to belong_to(:call_off_contract) }
    end

    describe "ranges" do
      it "uses only the first band if there are enough participants" do
        expect(bands[0].number_of_participants_in_this_band(100)).to eq(100)
        expect(bands[1].number_of_participants_in_this_band(100)).to eq(0)
        expect(bands[2].number_of_participants_in_this_band(100)).to eq(0)
        expect(bands[3].number_of_participants_in_this_band(100)).to eq(0)
      end

      it "fills band_a only if there are enough participants for just band_a" do
        expect(band_a.number_of_participants_in_this_band(2000)).to eq(2000)
        expect(band_b.number_of_participants_in_this_band(2000)).to eq(0)
        expect(band_c.number_of_participants_in_this_band(2000)).to eq(0)
        expect(band_d.number_of_participants_in_this_band(2000)).to eq(0)
      end

      it "fills band_a only if there are enough participants for just band_a" do
        expect(band_a.number_of_participants_in_this_band(2001)).to eq(2000)
        expect(band_b.number_of_participants_in_this_band(2001)).to eq(1)
        expect(band_c.number_of_participants_in_this_band(2001)).to eq(0)
        expect(band_a.number_of_participants_in_this_band(10_000)).to eq(2000)
        expect(band_b.number_of_participants_in_this_band(10_000)).to eq(2000)
        expect(band_c.number_of_participants_in_this_band(10_000)).to eq(500)
        expect(band_d.number_of_participants_in_this_band(10_000)).to eq(600)
      end
    end
  end
end
