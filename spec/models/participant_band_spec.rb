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
        expect(bands[1].min).to eq(bands[0].max + 1)
        expect(bands[2].min).to eq(bands[1].max + 1)
        expect(bands[2].max).to be_nil
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
        expect(bands[2].number_of_participants_in_this_band(10_000)).to eq(6000)
      end
    end
  end

  context "with revised recruitment target" do
    let(:call_off_contract) { create(:call_off_contract, recruitment_target: 4500, revised_target: 5100) }
    let(:bands) { call_off_contract.bands }

    describe "associations" do
      it { is_expected.to belong_to(:call_off_contract) }
    end

    describe "ranges" do
      it "orders the bands appropriately regardless of creation order" do
        expect(bands[0].min).to be_nil
        expect(bands[1].min).to eq(bands[0].max + 1)
        expect(bands[2].min).to eq(bands[1].max + 1)
        expect(bands[2].max).to eq(call_off_contract.recruitment_target)
        expect(bands[3].min).to eq(bands[2].max + 1)
        expect(bands[3].max).to eq(call_off_contract.revised_target)
        expect(bands[4]).to be_nil
      end

      it "uses only the first band if there are enough participants" do
        expect(bands[0].number_of_participants_in_this_band(100)).to eq(100)
        expect(bands[1].number_of_participants_in_this_band(100)).to eq(0)
        expect(bands[2].number_of_participants_in_this_band(100)).to eq(0)
        expect(bands[3].number_of_participants_in_this_band(100)).to eq(0)
      end

      it "fills bands[0] only if there are enough participants for just bands[0]" do
        expect(bands[0].number_of_participants_in_this_band(2000)).to eq(2000)
        expect(bands[1].number_of_participants_in_this_band(2000)).to eq(0)
        expect(bands[2].number_of_participants_in_this_band(2000)).to eq(0)
        expect(bands[3].number_of_participants_in_this_band(2000)).to eq(0)
      end

      it "populates bands[1] if there are enough participants for bands[0] + bands[1]" do
        expect(bands[0].number_of_participants_in_this_band(2001)).to eq(2000)
        expect(bands[1].number_of_participants_in_this_band(2001)).to eq(1)
        expect(bands[2].number_of_participants_in_this_band(2001)).to eq(0)
        expect(bands[3].number_of_participants_in_this_band(2001)).to eq(0)
      end

      it "fills bands[1] if there are enough participants for just bands[0] + bands[1]" do
        expect(bands[0].number_of_participants_in_this_band(4000)).to eq(2000)
        expect(bands[1].number_of_participants_in_this_band(4000)).to eq(2000)
        expect(bands[2].number_of_participants_in_this_band(4000)).to eq(0)
        expect(bands[3].number_of_participants_in_this_band(4000)).to eq(0)
      end

      it "fills all the bands but no more if there are more participants than the revised recruitment target" do
        expect(bands[0].number_of_participants_in_this_band(10_000)).to eq(2000)
        expect(bands[1].number_of_participants_in_this_band(10_000)).to eq(2000)
        expect(bands[2].number_of_participants_in_this_band(10_000)).to eq(500)
        expect(bands[3].number_of_participants_in_this_band(10_000)).to eq(600)
      end
    end
  end
end
