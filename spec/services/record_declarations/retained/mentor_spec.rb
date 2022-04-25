# frozen_string_literal: true

require "rails_helper"
require_relative "../../../shared/context/service_record_declaration_params"
require_relative "../../../shared/context/lead_provider_profiles_and_courses"

RSpec.describe RecordDeclarations::Retained::Mentor do
  include_context "lead provider profiles and courses"
  include_context "service record declaration params"

  let(:cutoff_start_datetime) { mentor_profile.schedule.milestones[1].start_date.beginning_of_day }
  let(:cutoff_end_datetime) { mentor_profile.schedule.milestones[1].milestone_date.end_of_day }
  let(:retained_mentor_params) { mentor_params.merge(declaration_type: "retained-1", declaration_date: (cutoff_start_datetime + 1.day).rfc3339, evidence_held: "other") }

  before do
    travel_to cutoff_start_datetime + 2.days
    create(:ecf_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider: cpd_lead_provider)
  end

  it_behaves_like "a participant declaration with evidence held service" do
    def given_params
      retained_mentor_params
    end

    def given_profile
      mentor_profile
    end
  end

  it_behaves_like "a participant service for mentor" do
    def given_params
      retained_mentor_params
    end
  end

  context "when valid user is a mentor" do
    %w[training-event-attended self-study-material-completed].each do |evidence_held|
      it "creates a participant and profile declaration for evidence #{evidence_held}" do
        expect { described_class.call(params: retained_mentor_params.merge(evidence_held: evidence_held)) }
            .to change { ParticipantDeclaration.count }.by(1)
      end
    end
  end
end
