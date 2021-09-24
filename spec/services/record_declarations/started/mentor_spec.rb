# frozen_string_literal: true

require "rails_helper"

require_relative "../../../shared/context/service_record_declaration_params"
require_relative "../../../shared/context/lead_provider_profiles_and_courses"

RSpec.describe RecordDeclarations::Started::Mentor do
  include_context "lead provider profiles and courses"
  include_context "service record declaration params"

  let(:cutoff_start_datetime) { mentor_profile.schedule.milestones.first.start_date.beginning_of_day }
  let(:cutoff_end_datetime) { mentor_profile.schedule.milestones.first.milestone_date.end_of_day }

  before do
    travel_to cutoff_start_datetime + 2.days
  end

  it_behaves_like "a started participant declaration service" do
    def given_params
      mentor_params
    end

    def given_profile
      mentor_profile
    end
  end

  context "when valid user is an mentor" do
    it "fails when course is for an early_career_teacher" do
      params = mentor_params.merge({ course_identifier: "ecf-induction" })
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is npq" do
      params = mentor_params.merge({ course_identifier: "npq-headship" })
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when user profile is a withdrawn record" do
      User.find(mentor_params[:participant_id]).mentor_profile.withdrawn_record!
      expect { described_class.call(mentor_params) }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
