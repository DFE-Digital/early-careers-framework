# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckParticipantEligibility do
  subject(:service) { described_class }

  describe ".call" do
    context "when a matching ineligible participant record exists" do
      let!(:ineligible_participant) { create(:ineligible_participant, trn: "1234567", reason: "previous_participation") }

      it "returns the ineligibility reason" do
        expect(service.call(trn: "1234567")).to eq :previous_induction_and_participation
      end
    end

    context "when no matching ineligible participant record exists" do
      it "returns previous_induction" do
        expect(service.call(trn: "9876543")).to eq :previous_induction
      end
    end

    context "when an previous_induction record exists" do
      let!(:eligible_participant) { create(:ineligible_participant, trn: "1234567", reason: "previous_induction") }

      it "returns nil" do
        expect(service.call(trn: "1234567")).to be_nil
      end
    end

    context "when a previous_induction and previous_participation record exists" do
      let!(:ineligible_participant) { create(:ineligible_participant, trn: "1234567", reason: "previous_induction_and_participation") }

      it "returns previous_participation" do
        expect(service.call(trn: "1234567")).to eq :previous_participation
      end
    end
  end
end
