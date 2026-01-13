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
      session = { add_participant_wizard: { participant_profile: participant_profile } }
      store = described_class.new(
        session:,
        form_key: :add_participant_wizard,
      )

      fresh_profile = store.participant_profile

      expect(fresh_profile).to have_attributes(id: participant_profile.id)
      expect(fresh_profile).not_to be(participant_profile)
      expect(session[:add_participant_wizard][:participant_profile]).to eq(participant_profile.id)
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
