# frozen_string_literal: true

require "rails_helper"
require_relative "../../../shared/context/service_record_declaration_params.rb"
require_relative "../../../shared/context/lead_provider_profiles_and_courses.rb"

RSpec.describe RecordDeclarations::Retained::NPQ do
  include_context "lead provider profiles and courses"
  include_context "service record declaration params"

  before do
    travel_to ect_profile.schedule.milestones.first.start_date + 2.days
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

  context "when declaration type is invalid" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params.merge(declaration_type: "invalid")) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when declaration type is valid for ECF but not NPQ" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params.merge(declaration_type: "retained-3")) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when evidence held is invalid" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params.merge(evidence_held: "invalid")) }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
