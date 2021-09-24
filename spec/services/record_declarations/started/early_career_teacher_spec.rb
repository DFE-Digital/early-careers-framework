# frozen_string_literal: true

require "rails_helper"

require_relative "../../../shared/context/service_record_declaration_params"
require_relative "../../../shared/context/lead_provider_profiles_and_courses"

RSpec.describe RecordDeclarations::Started::EarlyCareerTeacher do
  include_context "lead provider profiles and courses"
  include_context "service record declaration params"

  let(:cutoff_start_datetime) { ect_profile.schedule.milestones.find_by(declaration_type: "started").start_date.beginning_of_day }
  let(:cutoff_end_datetime) { ect_profile.schedule.milestones.find_by(declaration_type: "started").milestone_date.end_of_day }

  before do
    travel_to cutoff_start_datetime + 2.days
  end

  it_behaves_like "a started participant declaration service" do
    def given_params
      ect_params
    end

    def given_profile
      ect_profile
    end
  end

  context "when valid user is an early_career_teacher" do
    it "fails when course is for mentor" do
      params = ect_params.merge({ course_identifier: "ecf-mentor" })
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is npq" do
      params = ect_params.merge({ course_identifier: "npq-headship" })
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when user profile is a withdrawn record" do
      User.find(ect_params[:participant_id]).early_career_teacher_profile.withdrawn_record!
      expect { described_class.call(ect_params) }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
