# frozen_string_literal: true

require "rails_helper"

require_relative "../../../shared/context/lead_provider_profiles_and_courses.rb"

RSpec.describe Participants::ChangeSchedule::EarlyCareerTeacher do
  include_context "lead provider profiles and courses"

  let(:participant_params) do
    {
      cpd_lead_provider: cpd_lead_provider,
      participant_id: ect_profile.user.id,
      course_identifier: "ecf-induction",
      schedule_identifier: "ecf-september-extended-2021",
    }
  end

  before do
    create(:schedule, schedule_identifier: "ecf-september-extended-2021")
  end

  context "when lead providers don't match" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params: participant_params.merge({ cpd_lead_provider: another_lead_provider })) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when valid user is an early_career_teacher" do
    it "changes the schedule on user's profile" do
      expect(ect_profile.reload.schedule.schedule_identifier).to eq("ecf-september-standard-2021")
      described_class.call(params: participant_params)
      expect(ect_profile.reload.schedule.schedule_identifier).to eq("ecf-september-extended-2021")
    end

    it "fails when the schedule is invalid" do
      params = participant_params.merge({ schedule_identifier: "wibble" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when the participant is withdrawn" do
      ParticipantProfileState.create!(participant_profile: ect_profile, state: "withdrawn")
      expect { described_class.call(params: participant_params) }
        .to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is for a mentor" do
      params = participant_params.merge({ course_identifier: "ecf-mentor" })
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
