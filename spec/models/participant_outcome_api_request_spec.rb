# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantOutcomeApiRequest, :with_default_schedules, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:participant_outcome).class_name("ParticipantOutcome::NPQ") }
  end

  describe "scopes" do
    describe ".trn_not_found" do
      let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
      let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
      let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
      let(:user) { create(:user, full_name: "John Doe") }
      let(:teacher_profile) { create(:teacher_profile, user:, trn: "1234567") }
      let(:participant_profile) { create(:npq_participant_profile, npq_lead_provider:, npq_course:, teacher_profile:, user:) }
      let(:participant_declaration) { create(:npq_participant_declaration, npq_course:, cpd_lead_provider:, participant_profile:) }
      let(:participant_outcome) { create(:participant_outcome, participant_declaration:) }

      context "with trn not found errors" do
        let!(:participant_outcome_api_request) { create(:participant_outcome_api_request, :with_trn_not_found, participant_outcome:) }

        it "returns the correct records" do
          expect(described_class.trn_not_found).to include(participant_outcome_api_request)
        end
      end

      context "with no errors" do
        let!(:participant_outcome_api_request) { create(:participant_outcome_api_request, participant_outcome:) }

        it "returns the correct records" do
          expect(described_class.trn_not_found).not_to include(participant_outcome_api_request)
        end
      end
    end
  end
end
