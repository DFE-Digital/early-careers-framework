# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::NPQ::ApplicationStatusQuery do
  let(:participant_declaration) { create(:npq_participant_declaration) }
  let(:npq_application) { create(:npq_application, participant_identity_id: participant_declaration.participant_profile.participant_identity.id) }
  let(:participant_outcome) { create(:participant_outcome, participant_declaration:) }
  let(:service) { described_class.new(npq_application) }
  describe "#call" do
    context "when a participant declaration exists" do
      before do
        allow(NPQApplication).to receive(:participant_declaration_finder).and_return(participant_declaration)
      end
      context "when a participant outcome exists" do
        before do
          allow(ParticipantOutcome::NPQ).to receive(:latest_per_declaration).and_return(participant_outcome)
        end
        it "returns the latest state of the participant outcome which is only one created" do
          expect(service.call).to eq(participant_outcome.state)
        end
      end
      context "when no participant outcome exists" do
        before do
          allow(ParticipantOutcome::NPQ).to receive(:latest_per_declaration).and_return(nil)
        end
        it "returns nil" do
          expect(service.call).to be_nil
        end
      end
    end
    context "when no participant declaration exists" do
      before do
        allow(NPQApplication).to receive(:participant_declaration_finder).and_return(nil)
      end
      it "returns nil" do
        expect(service.call).to be_nil
      end
    end
  end
end
