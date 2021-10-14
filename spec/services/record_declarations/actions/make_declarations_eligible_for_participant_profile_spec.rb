# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Actions::MakeDeclarationsEligibleForParticipantProfile do
  let!(:started) { create(:ect_participant_declaration) }
  let!(:participant_profile) { started.participant_profile }
  let!(:user) { started.user }
  let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile: participant_profile) }

  context "#call" do
    it "starts with all declarations set to submitted" do
      ParticipantDeclaration.all.each do |participant_declaration|
        expect(participant_declaration.submitted?).to be_truthy
      end
    end

    it "marks any submitted declarations for the participant as eligible" do
      eligibility.eligible_status!
      described_class.call(participant_profile: participant_profile)  # TODO: Remove this line when it's wired up automatically to the eligibility status check.
      ParticipantDeclaration.all.each do |participant_declaration|
        expect(participant_declaration.eligible?).to be_truthy
      end
    end
  end
end
