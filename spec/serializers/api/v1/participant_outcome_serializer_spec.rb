# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ParticipantOutcomeSerializer, :with_default_schedules do
  describe "#serializable_hash" do
    let(:provider) { create :cpd_lead_provider, :with_npq_lead_provider }
    let(:npq_application) { create :npq_application, :accepted, npq_lead_provider: provider.npq_lead_provider }
    let(:declaration) { create :npq_participant_declaration, participant_profile: npq_application.profile, cpd_lead_provider: provider }
    subject(:outcome) { create :participant_outcome, participant_declaration: declaration }

    it "serialises to the correct structure" do
      result = described_class.new(outcome).serializable_hash
      expected = {
        data: {
          id: outcome.id,
          type: :"participant-outcome",
          attributes: {
            completion_date: outcome.completion_date.rfc3339,
            participant_id: npq_application.participant_identity.external_identifier,
            course_identifier: declaration.course_identifier,
          },
        },
      }
      expect(result).to eql(expected)
    end
  end
end
