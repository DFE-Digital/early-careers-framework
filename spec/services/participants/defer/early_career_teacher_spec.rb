# frozen_string_literal: true

require "rails_helper"

require_relative "../../../shared/context/lead_provider_profiles_and_courses.rb"

RSpec.describe Participants::Defer::EarlyCareerTeacher do
  include_context "lead provider profiles and courses"
  let(:participant_params) do
    {
      cpd_lead_provider: cpd_lead_provider,
      participant_id: ect_profile.user.id,
      course_identifier: "ecf-induction",
      reason: "career-break",
    }
  end

  context "when lead providers don't match" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params: participant_params.merge({ cpd_lead_provider: another_lead_provider })) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when valid user is an early_career_teacher" do
    it "creates a deferred state for that user's profile" do
      expect { described_class.call(params: participant_params.merge(reason: "adoption")) }
        .to change { ParticipantProfileState.count }.by(1)
    end

    it "fails when the reason is invalid" do
      params = participant_params.merge({ reason: "wibble" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when the participant is already deferred" do
      described_class.call(params: participant_params.merge(reason: "adoption"))
      expect { described_class.call(params: participant_params.merge(reason: "adoption")) }
        .to raise_error(ActiveRecord::RecordInvalid)
    end

    it "fails when the participant is already withdrawn" do
      Participants::Withdraw::EarlyCareerTeacher.call(params: participant_params)
      expect { described_class.call(params: participant_params.merge({reason: "adoption"})) }
        .to raise_error(ActiveRecord::RecordInvalid)
    end

    it "fails when course is for a mentor" do
      params = participant_params.merge({ course_identifier: "ecf-mentor", reason: "adoption" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is for an npq-course" do
      params = participant_params.merge({ course_identifier: "npq-leading-teacher", reason: "adoption" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when user is not a participant" do
    it "raises ParameterMissing for an invalid user_id and not change participant profile state" do
      expect { described_class.call(params: participant_params.except(:participant_id)) }.to raise_error(ActionController::ParameterMissing).and(not_change { ParticipantProfileState.count })
    end
  end
end
