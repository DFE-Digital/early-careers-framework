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
    create(:ecf_statement, :output_fee, deadline_date: 6.weeks.from_now)
  end

  it_behaves_like "a participant declaration without evidence held service" do
    def given_params
      ect_params
    end

    def given_profile
      ect_profile
    end
  end

  it_behaves_like "a participant service for ect" do
    def given_params
      ect_params
    end

    def user_profile
      ect_profile
    end
  end

  context "when user is for 2020 cohort" do
    let!(:cohort_2020) { create(:cohort, start_year: 2020) }
    let!(:school_cohort_2020) { create(:school_cohort, cohort: cohort_2020, school: ect_profile.school) }

    before do
      induction_programme.update!(school_cohort: school_cohort_2020)
    end

    it "raises a ParameterMissing error" do
      expect { described_class.call(params: ect_params) }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
