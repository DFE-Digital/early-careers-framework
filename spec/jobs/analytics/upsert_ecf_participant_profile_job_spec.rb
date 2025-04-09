# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::UpsertECFParticipantProfileJob do
  describe "#perform" do
    it "calls Analytics::ECFValidationService.upsert_record when the participant profile exists" do
      participant_profile = create(:ect)
      expect(Analytics::ECFValidationService).to receive(:upsert_record).with(participant_profile)

      described_class.new.perform(participant_profile_id: participant_profile.id)
    end

    it "does not call Analytics::ECFValidationService.upsert_record when the participant profile does not exist" do
      expect(Analytics::ECFValidationService).not_to receive(:upsert_record)

      described_class.new.perform(participant_profile_id: SecureRandom.uuid)
    end
  end
end
