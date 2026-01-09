# frozen_string_literal: true

require "rails_helper"

RSpec.describe FormData::AddParticipantStore, type: :model do
  describe "#participant_profile" do
    it "returns the profile when the session stores an id" do
      participant_profile = create(:ect_participant_profile)
      store = described_class.new(
        session: { add_participant_wizard: { participant_profile: participant_profile.id } },
        form_key: :add_participant_wizard,
      )

      expect(store.participant_profile).to eq(participant_profile)
    end

    it "returns the profile when the session stores the record" do
      participant_profile = create(:ect_participant_profile)
      store = described_class.new(
        session: { add_participant_wizard: { participant_profile: participant_profile } },
        form_key: :add_participant_wizard,
      )

      expect(store.participant_profile).to eq(participant_profile)
    end

    it "returns nil when the session value is blank" do
      store = described_class.new(
        session: { add_participant_wizard: { participant_profile: nil } },
        form_key: :add_participant_wizard,
      )

      expect(store.participant_profile).to be_nil
    end
  end
end
