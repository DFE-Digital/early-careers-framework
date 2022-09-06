# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Actions::MakeDeclarationsEligibleForParticipantProfile, :with_default_schedules do
  let!(:declaration) { create(:ect_participant_declaration) }
  let!(:participant_profile) { declaration.participant_profile }

  context "::call" do
    let(:mock_attacher) { instance_double(Finance::DeclarationStatementAttacher, call: nil) }

    before do
      allow(Finance::DeclarationStatementAttacher).to receive(:new).with(declaration).and_return(mock_attacher)
    end

    it "marks any submitted declarations for the participant as eligible" do
      expect {
        described_class.call(participant_profile:)
      }.to change { declaration.reload.state }.from("submitted").to("eligible")
    end

    it "attaches the declaration to relevant statement" do
      described_class.call(participant_profile:)

      expect(mock_attacher).to have_received(:call)
    end
  end
end
