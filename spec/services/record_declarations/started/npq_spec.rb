# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Started::NPQ do
  let(:cpd_lead_provider) { create(:cpd_lead_provider) }
  let(:another_lead_provider) { create(:cpd_lead_provider, name: "Unknown") }
  let(:npq_lead_provider) { create(:npq_lead_provider, cpd_lead_provider: cpd_lead_provider) }
  let(:npq_course) { create(:npq_course, identifier: "npq-leading-teaching") }
  let!(:npq_profile) do
    create(:npq_validation_data,
           npq_lead_provider: npq_lead_provider,
           npq_course: npq_course)
  end
  let(:induction_coordinator_profile) { create(:induction_coordinator_profile) }
  let(:params) do
    {
      user_id: npq_profile.user_id,
      declaration_date: "2021-06-21T08:46:29Z",
      declaration_type: "started",
      course_identifier: "npq-leading-teaching",
      lead_provider_from_token: another_lead_provider,
    }
  end

  let(:npq_params) do
    params.merge({ lead_provider_from_token: cpd_lead_provider })
  end
  let(:induction_coordinator_params) do
    npq_params.merge({ user_id: induction_coordinator_profile.user_id })
  end

  context "when sending event for an npq course" do
    it "creates a participant and profile declaration" do
      expect { described_class.call(npq_params) }.to change { ParticipantDeclaration.count }.by(1).and change { ProfileDeclaration.count }.by(1)
    end
  end

  context "when user is not a participant" do
    it "does not create a declaration record and raises ParameterMissing for an invalid user_id" do
      expect { described_class.call(induction_coordinator_params) }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
