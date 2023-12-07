# frozen_string_literal: true

require "rails_helper"

RSpec.describe Archive::UserPresenter do
  include ArchiveHelper

  let(:id) { SecureRandom.uuid }
  let(:alt_id) { SecureRandom.uuid }
  let(:profile_id) { SecureRandom.uuid }
  let(:trn) { "0012345" }
  let(:user) { build_archived_ect(name: "Adam West", id:, alt_id:, profile_id:, trn:) }
  subject(:presenter) { described_class.new(user.data) }

  describe "#trn" do
    it "returns the TRN from the archive" do
      expect(presenter.trn).to eq trn
    end
  end

  describe "#created_at" do
    it "returns the user creation date" do
      expect(presenter.created_at).to eq Time.zone.parse(user.data.dig("attributes", "created_at"))
    end
  end

  describe "#participant_identities" do
    it "returns the user's identity records" do
      identities = Archive::ParticipantIdentityPresenter.wrap(user.data.dig("attributes", "participant_identities"))
      expect(presenter.participant_identities.map(&:id)).to match_array identities.map(&:id)
    end
  end

  describe "#participant_profiles" do
    it "returns the user's participant profile records" do
      profiles = Archive::ParticipantProfilePresenter.wrap(user.data.dig("attributes", "participant_profiles"))
      expect(presenter.participant_profiles.map(&:id)).to match_array profiles.map(&:id)
    end
  end
end
