# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::NPQ::ApplicationSynchronizationSerializer do
  let(:npq_application) { create(:npq_application, :accepted) }
  let(:pick_application) { NPQApplication.where(id: npq_application.id).pick(:lead_provider_approval_status, :id, :participant_identity_id) }
  let(:participant_declaration) { create(:npq_participant_declaration, cpd_lead_provider: npq_application.npq_lead_provider.cpd_lead_provider, participant_profile: npq_application.profile) }
  let!(:participant_outcome) { create(:participant_outcome, participant_declaration:) }

  before { participant_declaration.update!(declaration_type: "completed") }

  describe "#serializable_hash" do
    it "serialises to the correct structure" do
      result = described_class.new(npq_application).serializable_hash

      expected = {
        data: {
          id: npq_application.id,
          type: :application_synchronization,
          attributes: {
            id: npq_application.id,
            lead_provider_approval_status: "accepted",
            participant_outcome_state: "passed",
          },
        },
      }

      expect(result).to eql(expected)
    end
  end
end
