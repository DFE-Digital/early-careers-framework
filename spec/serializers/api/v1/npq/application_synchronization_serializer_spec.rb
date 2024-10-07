# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::NPQ::ApplicationSynchronizationSerializer do
  let(:npq_application) { create(:npq_application, :accepted) }
  let(:pick_application) { NPQApplication.where(id: npq_application.id).pick(:lead_provider_approval_status, :id, :participant_identity_id) }
  let(:declaration_date) { npq_application.profile.schedule.milestones.find_by(declaration_type: "completed").start_date }
  let!(:participant_declaration) do
    travel_to declaration_date + 2.days do
      create(:npq_participant_declaration, declaration_type: "completed", cpd_lead_provider: npq_application.npq_lead_provider.cpd_lead_provider, participant_profile: npq_application.profile, declaration_date:)
    end
  end
  let!(:participant_outcome) { create(:participant_outcome, :failed, participant_declaration:) }

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
            participant_outcome_state: "failed",
          },
        },
      }

      expect(result).to eql(expected)
    end
  end
end
