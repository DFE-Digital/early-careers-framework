# frozen_string_literal: true

require "rails_helper"

require_relative "../../../shared/context/lead_provider_profiles_and_courses"

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

  it_behaves_like "a participant change schedule action service" do
    def given_params
      participant_params
    end

    def user_profile
      ect_profile.reload
    end
  end

  context "when valid user is an early_career_teacher" do
    it "fails when course is for a mentor" do
      params = participant_params.merge({ course_identifier: "ecf-mentor" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is for an npq-course" do
      params = participant_params.merge({ course_identifier: "npq-leading-teacher" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
