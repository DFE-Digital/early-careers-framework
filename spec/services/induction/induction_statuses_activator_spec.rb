# frozen_string_literal: true

RSpec.describe Induction::InductionStatusesActivator do
  describe "#call" do
    let(:induction_record) { create(:induction_record, induction_status:) }
    let(:participant_profile) { induction_record.participant_profile }

    subject(:service) { described_class }

    describe ".call" do
      before do
        service.call(participant_profile:)
      end

      context "when participant's induction record has withdrawn induction status" do
        let(:induction_status) { "withdrawn" }

        it "creates a new inductιon record" do
          expect(participant_profile.induction_records.count).to eq(2)
        end

        it "sets the inductιon record induction status and the participant status to active" do
          expect(participant_profile.latest_induction_record.induction_status).to eq("active")
          expect(participant_profile.status).to eq("active")
        end
      end

      context "when participant's induction record has leaving induction status" do
        let(:induction_status) { "leaving" }

        it "creates a new inductιon record" do
          expect(participant_profile.induction_records.count).to eq(2)
        end

        it "sets the inductιon record induction status and the participant status to active" do
          expect(participant_profile.latest_induction_record.induction_status).to eq("active")
          expect(participant_profile.status).to eq("active")
        end
      end

      context "when participant's induction record has not withdrawn or leaving induction status" do
        let(:induction_status) { "active" }

        it "does not creates a new inductιon record" do
          expect(participant_profile.induction_records.count).to eq(1)
        end
      end
    end
  end
end
