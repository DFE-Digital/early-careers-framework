# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::NPQ::ApplicationSynchronizationSerializer, :with_default_schedules do
  describe "serialization" do
    context "when serializer got a request to serialize data" do
      let(:participant_identity) { create(:participant_identity) }
      let(:npq_application) { create(:npq_application, participant_identity:) }
      let(:serializer) { described_class.new(npq_application) }
      let(:npq_participant_declaration) { create(:npq_participant_declaration, user: participant_identity.user) }

      it "serializes the lead_provider_approval_status attribute" do
        expect(serializer.serializable_hash[:data][:attributes][:lead_provider_approval_status]).to eq(npq_application.lead_provider_approval_status)
      end

      it "serializes the id attribute" do
        expect(serializer.serializable_hash[:data][:id]).to eq(npq_application.id)
      end

      it "serializes the participant_outcome_state attribute based on latest declaration and outcome" do
        outcome = create(:participant_outcome, participant_declaration: npq_participant_declaration)
        expect(serializer.serializable_hash[:data][:attributes][:participant_outcome_state]).to eq(outcome&.state)
      end
    end
  end
end
