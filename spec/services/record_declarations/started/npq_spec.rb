# frozen_string_literal: true

require "rails_helper"

require_relative "../../../shared/context/service_record_declaration_params"
require_relative "../../../shared/context/lead_provider_profiles_and_courses"

RSpec.describe RecordDeclarations::Started::NPQ do
  include_context "lead provider profiles and courses"
  include_context "service record declaration params"

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
