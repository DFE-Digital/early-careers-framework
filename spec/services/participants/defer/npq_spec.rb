# frozen_string_literal: true

require "rails_helper"

require_relative "../../../shared/context/lead_provider_profiles_and_courses"

RSpec.describe Participants::Defer::NPQ do
  include_context "lead provider profiles and courses"

  let(:participant_params) do
    {
      cpd_lead_provider: cpd_lead_provider,
      participant_id: npq_profile.user.id,
      course_identifier: "npq-leading-teaching",
      reason: "adoption",
    }
  end

  it_behaves_like "a participant defer action service" do
    def given_params
      participant_params
    end

    def user_profile
      npq_profile.reload
    end
  end

  context "when valid user is an NPQ" do
    it "fails when course is for an early career teacher" do
      params = participant_params.merge({ course_identifier: "ecf-induction" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is for a mentor" do
      params = participant_params.merge({ course_identifier: "ecf-mentor" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is for a different npq-course" do
      params = participant_params.merge({ course_identifier: "npq-headship" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
