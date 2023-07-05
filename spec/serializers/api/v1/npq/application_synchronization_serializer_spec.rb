# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::NPQ::ApplicationSynchronizationSerializer do
  let(:npq_application) { create(:npq_application) }
  let(:pick_application) { NPQApplication.where(id: npq_application.id).pick(:lead_provider_approval_status, :id, :participant_identity_id) }
  let(:state) do
    participant_declaration_id = NPQApplication.participant_declaration_finder(pick_application.last)&.id
    ParticipantOutcome::NPQ.latest_per_declaration&.find_by_participant_declaration_id(participant_declaration_id)&.state
  end

  describe "#serializable_hash" do
    it "serialises to the correct structure" do
      result = described_class.new(npq_application).serializable_hash
      expected = {
        data: {
          id: npq_application.id,
          type: :application_synchronization,
          attributes: {
            id: npq_application.id,
            lead_provider_approval_status: npq_application.lead_provider_approval_status,
            participant_outcome_state: state,
          },
        },
      }
      expect(result).to eql(expected)
    end
  end
end
