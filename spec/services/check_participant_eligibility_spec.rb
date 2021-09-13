# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckParticipantEligibility do
  subject(:service) { described_class }


  describe ".call" do
    context "when a matching ineligible participant record exists" do
      let!(:ineligible_participant) { create(:ineligible_participant, trn: "1234567", reason: "previous_participation") }

      it "returns the ineligibility reason" do
        expect(service.call(trn: "1234567")).to eq :previous_participation
      end
    end

    context "when no matching ineligible participan record exists" do
      it "returns nil" do
        expect(service.call(trn: "9876543")).to be_nil
      end
    end
  end
end
