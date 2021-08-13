# frozen_string_literal: true

require "rails_helper"

require_relative "../../../shared/context/service_record_declaration_params.rb"
require_relative "../../../shared/context/lead_provider_profiles_and_courses.rb"

RSpec.describe RecordDeclarations::Started::Mentor do
  include_context "lead provider profiles and courses"
  include_context "service record declaration params"

  before do
    travel_to ect_profile.schedule.milestones.first.start_date + 2.days
  end

  context "when lead providers don't match" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when valid user is a mentor" do
    it "creates a participant and profile declaration" do
      expect { described_class.call(mentor_params) }.to change { ParticipantDeclaration.count }.by(1).and change { ProfileDeclaration.count }.by(1)
    end

    it "fails when course is for an early_career_teacher" do
      params = mentor_params.merge({ course_identifier: "ecf-induction" })
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when user is not a participant" do
    it "does not create a declaration record and raises ParameterMissing for an invalid user_id" do
      expect { described_class.call(induction_coordinator_params) }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
