# frozen_string_literal: true

require "rails_helper"

require_relative "../shared/context/service_record_declaration_params"
require_relative "../shared/context/lead_provider_profiles_and_courses"

RSpec.describe RecordParticipantDeclaration do
  include_context "lead provider profiles and courses"
  include_context "service record declaration params"

  before do
    travel_to ect_profile.schedule.milestones.first.start_date + 4.days
  end

  context "when sending event for an npq course" do
    it "creates a participant declaration" do
      expect { described_class.call(npq_params) }.to change { ParticipantDeclaration.count }.by(1)
    end

    context "when the npq application is eligible for funding" do
      before do
        npq_profile.npq_application.update!(eligible_for_funding: true)
      end

      it "creates the participant declaration in the eligible state" do
        described_class.call(npq_params)
        declaration = npq_profile.participant_declarations.first
        expect(declaration.state).to eq "eligible"
      end
    end

    context "when the npq application is not eligible for funding" do
      before do
        npq_profile.npq_application.update!(eligible_for_funding: false)
      end

      it "creates the participant declaration in the submitted state" do
        described_class.call(npq_params)
        declaration = npq_profile.participant_declarations.first
        expect(declaration.state).to eq "submitted"
      end
    end
  end

  context "when sending event for an ect course" do
    context "when lead providers don't match" do
      it "raises a ParameterMissing error" do
        expect { described_class.call(ect_params.merge(cpd_lead_provider: another_lead_provider)) }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when valid user is an early_career_teacher" do
      it "creates a participant and profile declaration" do
        expect { described_class.call(ect_params) }.to change { ParticipantDeclaration.count }.by(1)
      end

      it "fails when course is for mentor" do
        params = ect_params.merge({ course_identifier: "ecf-mentor" })
        expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when valid user is a mentor" do
      it "creates a participant and profile declaration" do
        expect { described_class.call(mentor_params) }.to change { ParticipantDeclaration.count }.by(1)
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

  context "when a voided payable declaration exists" do
    before do
      ect_profile.participant_declarations.create!(
        cpd_lead_provider: cpd_lead_provider,
        course_identifier: "ecf-induction",
        user: ect_profile.user,
        declaration_date: ect_profile.schedule.milestones.first.start_date - 1.week,
        declaration_type: "started",
        state: "voided",
      )
    end

    it "can re-submit the same declaration later" do
      expect { described_class.call(ect_params) }.to change { ParticipantDeclaration.count }.by(1)
    end
  end
end
