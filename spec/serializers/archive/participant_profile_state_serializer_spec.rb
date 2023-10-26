# frozen_string_literal: true

require "rails_helper"

RSpec.describe Archive::ParticipantProfileStateSerializer do
  let(:state) { create(:seed_ect_participant_profile_state, :valid) }

  subject { described_class.new(state) }

  describe "#serializable_hash" do
    it "generates the correct hash" do
      data = subject.serializable_hash[:data]
      expect(data[:id]).to eq state.id
      expect(data[:type]).to eq :participant_profile_state

      attrs = data[:attributes]
      expect(attrs[:participant_profile_id]).to eq state.participant_profile_id
      expect(attrs[:cpd_lead_provider_id]).to eq state.cpd_lead_provider_id
      expect(attrs[:state]).to eq state.state
      expect(attrs[:reason]).to eq state.reason
      expect(attrs[:created_at]).to eq state.created_at
    end
  end
end
