# frozen_string_literal: true

require "rails_helper"

require_relative "../../../shared/context/lead_provider_profiles_and_courses"

RSpec.describe Participants::Defer::Mentor, :with_default_schedules do
  include_context "lead provider profiles and courses"
  let(:participant_params) do
    {
      cpd_lead_provider: cpd_lead_provider,
      participant_id: mentor_profile.user.id,
      course_identifier: "ecf-mentor",
      reason: "career-break",
    }
  end

  it_behaves_like "a participant defer action service" do
    def given_params
      participant_params
    end

    def user_profile
      mentor_profile.reload
    end
  end

  it_behaves_like "a participant service for mentor" do
    def given_params
      participant_params
    end
  end
end
