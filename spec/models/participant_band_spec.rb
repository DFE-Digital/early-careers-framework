# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantBand, type: :model do
  context "without revision of recruitment target" do
    let(:call_off_contract) { create(:call_off_contract) }
    let(:bands) { call_off_contract.bands }

    describe "associations" do
      it { is_expected.to belong_to(:call_off_contract) }
    end

    describe "ranges" do
      it "orders the bands appropriately regardless of creation order" do
        expect(bands[0].min).to be_nil
        expect(bands[1].min).to eql(bands[0].max + 1)
        expect(bands[2].min).to eql(bands[1].max + 1)
        expect(bands[2].max).to eql(6_000)
        expect(bands[3]).to be_nil
      end

      it "uses only the first band if there are only enough participants for this band" do
        expect(bands[0].number_of_participants_in_this_band(100)).to eq(100)
        expect(bands[1].number_of_participants_in_this_band(100)).to eq(0)
        expect(bands[2].number_of_participants_in_this_band(100)).to eq(0)
        expect(bands[0].number_of_participants_in_this_band(2000)).to eq(2000)
        expect(bands[1].number_of_participants_in_this_band(2000)).to eq(0)
        expect(bands[2].number_of_participants_in_this_band(2000)).to eq(0)
      end

      it "uses the first two bands if there are only enough participants for the first two bands" do
        expect(bands[0].number_of_participants_in_this_band(2001)).to eq(2000)
        expect(bands[1].number_of_participants_in_this_band(2001)).to eq(1)
        expect(bands[2].number_of_participants_in_this_band(2001)).to eq(0)
      end

      it "uses three bands if there are enough participants for the first two bands" do
        expect(bands[0].number_of_participants_in_this_band(10_000)).to eq(2000)
        expect(bands[1].number_of_participants_in_this_band(10_000)).to eq(2000)
        expect(bands[2].number_of_participants_in_this_band(10_000)).to eq(2000)
      end

      context "when there are previous participants" do
        it "correctly calculates totals when a band is partially filled by previous participants" do
          # 2000 current participants, 2100 previous participants
          #  0             2000          4000          6000
          #  |              |             |             |
          #  |    Band A    |   Band B    |   Band C    |
          #  | ---------------|
          #             2100 previous participants
          #                    -------------|
          #             2000 current participants
          #
          # result is:
          # 0 current participants in Band A
          # 1900 current participants in Band B
          # 100 current participants in Band C
          expect(bands[0].number_of_participants_in_this_band(2000, 2100)).to eq(0)
          expect(bands[1].number_of_participants_in_this_band(2000, 2100)).to eq(1900)
          expect(bands[2].number_of_participants_in_this_band(2000, 2100)).to eq(100)
        end

        it "correctly calculates totals when a band is fully filled by current participants" do
          # 2500 current participants, 1900 previous participants
          #  0             2000          4000          6000
          #  |              |             |             |
          #  |    Band A    |   Band B    |   Band C    |
          #  | -----------|
          #             1900 previous participants
          #                ------------------|
          #             2500 current participants
          #
          # result is:
          # 100 current participants in Band A
          # 2000 current participants in Band B
          # 400 current participants in Band C
          expect(bands[0].number_of_participants_in_this_band(2500, 1900)).to eq(100)
          expect(bands[1].number_of_participants_in_this_band(2500, 1900)).to eq(2000)
          expect(bands[2].number_of_participants_in_this_band(2500, 1900)).to eq(400)
        end
      end
    end
  end
end
