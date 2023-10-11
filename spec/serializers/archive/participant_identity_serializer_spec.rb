# frozen_string_literal: true

require "rails_helper"

RSpec.describe Archive::ParticipantIdentitySerializer do
  let(:profile) { create(:seed_ect_participant_profile, :valid) }
  let(:identity) { profile.participant_identity }

  subject { described_class.new(identity) }

  describe "#serializable_hash" do
    it "generates the correct hash" do
      data = subject.serializable_hash[:data]
      expect(data[:id]).to eq identity.id
      expect(data[:type]).to eq :participant_identity

      attrs = data[:attributes]
      expect(attrs[:email]).to eq identity.email
      expect(attrs[:external_identifier]).to eq identity.external_identifier
      expect(attrs[:origin]).to eq identity.origin
      expect(attrs[:created_at]).to eq identity.created_at
      expect(attrs[:participant_profiles]).to match_array [{ id: profile.id, type: profile.type }]
    end
  end
end
