# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::NPQ::ApplicationStatusQuery do
  let(:npq_application) { create(:npq_application, :accepted) }
  let(:participant_profile) { npq_application.profile }
  let(:participant_declaration) { create(:npq_participant_declaration, cpd_lead_provider: npq_application.npq_lead_provider.cpd_lead_provider, participant_profile:) }
  let!(:participant_outcome) { create(:participant_outcome, participant_declaration:) }
  let(:service) { described_class.new(npq_application) }

  describe "#call" do
    context "when a non completed participant declaration exists" do
      it "returns nil" do
        expect(service.call).to be_nil
      end
    end

    context "when a completed participant declaration exists" do
      before { participant_declaration.update!(declaration_type: "completed") }

      context "when a participant outcome exists" do
        it "returns the latest state of the participant outcome which is only one created" do
          expect(service.call).to eq("passed")
        end
      end

      context "when no participant outcome exists" do
        before { participant_outcome.update!(participant_declaration: create(:npq_participant_declaration)) }

        it "returns nil" do
          expect(service.call).to be_nil
        end
      end
    end

    context "when no participant declaration exists" do
      before { participant_declaration.update!(participant_profile: create(:npq_participant_profile)) }

      it "returns nil" do
        expect(service.call).to be_nil
      end
    end
  end
end
