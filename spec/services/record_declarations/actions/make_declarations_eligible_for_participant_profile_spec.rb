# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Actions::MakeDeclarationsEligibleForParticipantProfile do
  let!(:started) { create(:ect_participant_declaration) }
  let!(:participant_profile) { started.participant_profile }
  let!(:user) { started.user }
  let!(:eligibility) { create(:ecf_participant_eligibility, :ineligible, participant_profile:) }

  context "#call" do
    it "starts with all declarations set to submitted" do
      ParticipantDeclaration.all.each do |participant_declaration|
        expect(participant_declaration).to be_submitted
      end
    end

    it "marks any submitted declarations for the participant as eligible" do
      StoreParticipantEligibility.call(participant_profile:)
      ParticipantDeclaration.all.each do |participant_declaration|
        expect(participant_declaration).to be_eligible
      end
    end
  end
end
