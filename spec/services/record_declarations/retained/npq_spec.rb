# frozen_string_literal: true

require "rails_helper"
require_relative "../../../shared/context/service_record_declaration_params"
require_relative "../../../shared/context/lead_provider_profiles_and_courses"

RSpec.describe RecordDeclarations::Retained::NPQ do
  include_context "lead provider profiles and courses"
  include_context "service record declaration params"

  let(:cutoff_start_datetime) { npq_profile.schedule.milestones[1].start_date.beginning_of_day }
  let(:cutoff_end_datetime) { npq_profile.schedule.milestones[1].milestone_date.end_of_day }
  let(:retained_npq_params) { npq_params.merge(declaration_type: "retained-1", declaration_date: (cutoff_start_datetime + 1.day).rfc3339, evidence_held: "yes") }

  before do
    travel_to cutoff_start_datetime + 2.days
  end

  it_behaves_like "a retained participant declaration service" do
    def given_params
      retained_npq_params
    end

    def given_profile
      npq_profile
    end
  end

  it_behaves_like "a participant service for npq" do
    def given_params
      retained_npq_params
    end
  end

  context "when declaration type is valid for ECF but not NPQ" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params: retained_npq_params.merge(declaration_type: "retained-3")) }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
