# frozen_string_literal: true

require "rails_helper"

RSpec.describe RetryContinueTrainingParticipantsThatFailedCohortChangeJob do
  let(:participant_profiles) { create_list(:ect, 2) }

  before do
    participant_profiles.each do |participant_profile|
      ContinueTrainingCohortChangeError.create!(participant_profile:, message: "Can't change cohort")
    end
  end

  describe "#perform" do
    context "when there are continue training errors" do
      before do
        participant_profiles.each do |participant_profile|
          allow(Participants::RetryContinueTraining).to receive(:new).with(participant_profile:).and_call_original
        end
        described_class.perform_now
      end

      it "retry all of them" do
        participant_profiles.each do |participant_profile|
          expect(Participants::RetryContinueTraining).to have_received(:new).with(participant_profile:)
        end
      end
    end
  end
end
