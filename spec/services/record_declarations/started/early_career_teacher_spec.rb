# frozen_string_literal: true

require "rails_helper"

require_relative "../../../shared/context/service_record_declaration_params.rb"
require_relative "../../../shared/context/lead_provider_profiles_and_courses.rb"

RSpec.describe RecordDeclarations::Started::EarlyCareerTeacher do
  include_context "lead provider profiles and courses"
  include_context "service record declaration params"

  let(:cutoff_start_datetime) { ect_profile.schedule.milestones.first.start_date.beginning_of_day }
  let(:cutoff_end_datetime) { ect_profile.schedule.milestones.first.milestone_date.end_of_day }

  before do
    travel_to cutoff_start_datetime + 2.days
  end

  context "when lead providers don't match" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when valid user is an early_career_teacher" do
    let(:ect_params_with_different_date) do
      ect_params.merge({ declaration_date: (ect_declaration_date + 1.second).rfc3339 })
    end

    it "creates a participant and profile declaration" do
      expect { described_class.call(ect_params) }.to change { ParticipantDeclaration.count }.by(1).and change { ProfileDeclaration.count }.by(1)
    end

    it "does not create exact duplicates" do
      expect {
        described_class.call(ect_params)
        described_class.call(ect_params)
      }.to change { ParticipantDeclaration.count }.by(1).and change { ProfileDeclaration.count }.by(1)
    end

    it "does not create exact duplicates and throws an error" do
      expect {
        described_class.call(ect_params)
        described_class.call(ect_params_with_different_date)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "fails when course is for mentor" do
      params = ect_params.merge({ course_identifier: "ecf-mentor" })
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when user is not a participant" do
    it "does not create a declaration record and raises ParameterMissing for an invalid user_id" do
      expect { described_class.call(induction_coordinator_params) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when declaration date is invalid" do
    it "raises ParameterMissing error" do
      params = ect_params.merge({ declaration_date: "2021-06-21 08:46:29" })
      expected_msg = /The property '#\/declaration_date' must be a valid RCF3339 date/
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing, expected_msg)
    end
  end

  context "when declaration date is in future" do
    it "raised ParameterMissing error" do
      params = ect_params.merge({ declaration_date: (Time.zone.now + 100.years).rfc3339(9) })
      expected_msg = /The property '#\/declaration_date' can not declare a future date/
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing, expected_msg)
    end
  end

  context "when including evidence_held" do
    it "raised ParameterMissing error" do
      params = ect_params.merge(evidence_held: "self-study-material-completed")
      expected_msg = /Unpermitted parameter: evidence_held/
      expect { described_class.call(params) }.to raise_error(ActionController::UnpermittedParameters, expected_msg)
    end
  end

  context "when declaration date is in the past" do
    it "does not raise ParameterMissing error" do
      params = ect_params.merge({ declaration_date: (Time.zone.now - 1.day).rfc3339(9) })
      expect { described_class.call(params) }.to_not raise_error
    end
  end

  context "when declaration date is today" do
    it "does not raise ParameterMissing error" do
      params = ect_params.merge({ declaration_date: Time.zone.now.rfc3339(9) })
      expect { described_class.call(params) }.to_not raise_error
    end
  end

  context "when before the milestone start" do
    before do
      travel_to cutoff_start_datetime - 1.day
    end

    it "raises ParameterMissing error" do
      params = ect_params.merge({ declaration_date: (cutoff_start_datetime - 1.day).rfc3339 })
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when at the milestone start" do
    before do
      travel_to cutoff_start_datetime
    end

    it "raises ParameterMissing error" do
      params = ect_params.merge({ declaration_date: cutoff_start_datetime.rfc3339 })
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when in the middle of milestone" do
    before do
      travel_to cutoff_start_datetime + 2.days
    end

    it "does not raise ParameterMissing error" do
      params = ect_params.merge({ declaration_date: (cutoff_start_datetime + 2.days).rfc3339 })
      expect { described_class.call(params) }.to_not raise_error
    end
  end

  context "when at the milestone end" do
    before do
      travel_to cutoff_end_datetime
    end

    it "does not raise ParameterMissing error" do
      params = ect_params.merge({ declaration_date: cutoff_end_datetime.rfc3339 })
      expect { described_class.call(params) }.to_not raise_error
    end
  end

  context "when after the milestone start" do
    before do
      travel_to cutoff_end_datetime + 1.day
    end

    it "raises ParameterMissing error" do
      params = ect_params.merge({ declaration_date: (cutoff_end_datetime + 1.day).rfc3339 })
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
