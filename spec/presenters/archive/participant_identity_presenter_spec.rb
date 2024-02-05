# frozen_string_literal: true

require "rails_helper"

RSpec.describe Archive::ParticipantIdentityPresenter do
  include ArchiveHelper

  let(:participant_identity) { create(:seed_participant_identity, :valid) }
  # to JSON and parse back to ensure keys are strings not symbols
  let(:serialized_data) { JSON.parse(Archive::ParticipantIdentitySerializer.new(participant_identity).serializable_hash.to_json)["data"] }
  subject(:presenter) { described_class.new(serialized_data) }

  describe "#email" do
    it "returns the email" do
      expect(presenter.email).to eq participant_identity.email
    end
  end

  describe "#external_identifier" do
    it "returns the external_identifier" do
      expect(presenter.external_identifier).to eq participant_identity.external_identifier
    end
  end

  describe "#origin" do
    it "returns the origin" do
      expect(presenter.origin).to eq participant_identity.origin
    end
  end

  describe "#created_at" do
    it "returns the creation date" do
      expect(Time.zone.parse(presenter.created_at)).to be_within(1.second).of participant_identity.created_at
    end
  end
end
