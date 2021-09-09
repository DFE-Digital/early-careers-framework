# frozen_string_literal: true

require "rails_helper"

require_relative "../../../shared/context/lead_provider_profiles_and_courses.rb"

RSpec.describe Participants::Resume::Mentor do
  include_context "lead provider profiles and courses"
  let(:participant_params) do
    {
      cpd_lead_provider: cpd_lead_provider,
      participant_id: mentor_profile.user.id,
      course_identifier: "ecf-mentor",
    }
  end

  context "when lead providers don't match" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params: participant_params.merge({ cpd_lead_provider: another_lead_provider })) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when valid user is a mentor" do
    it "creates an active state for that user's profile" do
      expect { described_class.call(params: participant_params) }
          .to change { ParticipantProfileState.count }.by(1)
      expect { ParticipantProfileState.order(created_at: :desc).first.active? }
    end

    it "fails when the participant is already active" do
      ParticipantProfileState.create!(participant_profile: mentor_profile, state: "active")
      expect { described_class.call(params: participant_params) }
          .to raise_error(ActiveRecord::RecordInvalid)
    end

    it "fails when the participant is already withdrawn" do
      ParticipantProfileState.create!(participant_profile: mentor_profile, state: "withdrawn")
      expect { described_class.call(params: participant_params) }
          .to raise_error(ActiveRecord::RecordInvalid)
    end

    it "fails when course is for an early career teacher" do
      params = participant_params.merge({ course_identifier: "ecf-induction" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is for an npq-course" do
      params = participant_params.merge({ course_identifier: "npq-leading-teacher" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when user is not a participant" do
    it "raises ParameterMissing for an invalid user_id and not change participant profile state" do
      expect { described_class.call(params: participant_params.except(:participant_id)) }.to raise_error(ActionController::ParameterMissing).and(not_change { ParticipantProfileState.count })
    end
  end
end
