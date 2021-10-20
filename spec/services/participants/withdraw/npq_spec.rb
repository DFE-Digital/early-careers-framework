# frozen_string_literal: true

require "rails_helper"

require_relative "../../../shared/context/lead_provider_profiles_and_courses"

RSpec.describe Participants::Withdraw::NPQ do
  include_context "lead provider profiles and courses"

  let(:participant_params) do
    {
      cpd_lead_provider: cpd_lead_provider,
      participant_id: npq_profile.user.id,
      course_identifier: "npq-leading-teaching",
      reason: Participants::Withdraw::ValidateAndChangeState::REASONS.sample,
    }
  end

  it_behaves_like "a participant withdraw action service" do
    def given_params
      participant_params
    end

    def user_profile
      npq_profile.reload
    end
  end

  it_behaves_like "a participant service for npq" do
    def given_params
      participant_params
    end
  end
end
