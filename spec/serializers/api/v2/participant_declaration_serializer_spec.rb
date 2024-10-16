# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::ParticipantDeclarationSerializer do
  describe "#has_passed" do
    let(:declaration_type) { "completed" }
    let(:npq_course) { create(:npq_leadership_course) }
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
    let(:npq_application) { create(:npq_application, :accepted, npq_course:, npq_lead_provider: cpd_lead_provider.npq_lead_provider) }
    let(:declaration_date) { npq_application.profile.schedule.milestones.find_by(declaration_type:).start_date + 1.day }
    let(:participant_declaration) do
      travel_to declaration_date do
        create(:npq_participant_declaration, :eligible, declaration_type:, declaration_date:, has_passed:, participant_profile: npq_application.profile, cpd_lead_provider:)
      end
    end

    describe "when participant declaration does not have outcome" do
      let(:participant_declaration) do
        create(:npq_participant_declaration, :eligible, declaration_type: "started")
      end

      it "returns nil" do
        result = described_class.new(participant_declaration).serializable_hash
        expect(result[:data][:attributes][:has_passed]).to eql(nil)
      end
    end

    describe "when participant outcome is true" do
      let(:has_passed) { true }

      it "returns true" do
        result = described_class.new(participant_declaration).serializable_hash
        expect(result[:data][:attributes][:has_passed]).to eql(true)
      end
    end

    describe "when participant outcome is false" do
      let(:has_passed) { false }

      it "returns false" do
        result = described_class.new(participant_declaration).serializable_hash
        expect(result[:data][:attributes][:has_passed]).to eql(false)
      end
    end
  end
end
