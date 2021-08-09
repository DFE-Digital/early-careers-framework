# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Retained::EarlyCareerTeacher do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:another_lead_provider) { create(:cpd_lead_provider, name: "Unknown") }
  let(:ect_profile) { create(:early_career_teacher_profile) }
  let(:mentor_profile) { create(:mentor_profile) }
  let(:induction_coordinator_profile) { create(:induction_coordinator_profile) }
  let(:params) do
    {
      raw_event: "{\"participant_id\":\"37b300a8-4e99-49f1-ae16-0235672b6708\",\"declaration_type\":\"retained-1\",\"declaration_date\":\"2021-06-21T08:57:31Z\",\"course_identifier\":\"ecf-induction\"}",
      user_id: ect_profile.user.id,
      declaration_date: "2021-06-21T08:46:29Z",
      declaration_type: "retained-1",
      course_identifier: "ecf-induction",
      lead_provider_from_token: another_lead_provider,
      evidence_held: "other",
    }
  end
  let(:ect_params) do
    params.merge({ lead_provider_from_token: cpd_lead_provider })
  end
  let(:mentor_params) do
    ect_params.merge({ user_id: mentor_profile.user.id, course_identifier: "ecf-mentor" })
  end
  let(:induction_coordinator_params) do
    ect_params.merge({ user_id: induction_coordinator_profile.user_id })
  end
  let(:delivery_partner) { create(:delivery_partner) }
  let!(:school_cohort) { create(:school_cohort, school: ect_profile.school, cohort: ect_profile.cohort) }
  let!(:partnership) do
    create(:partnership,
           school: ect_profile.school,
           lead_provider: cpd_lead_provider.lead_provider,
           cohort: ect_profile.cohort,
           delivery_partner: delivery_partner)
  end

  def generate_raw_event(params)
    params.except(:raw_event, :cpd_lead_provider).to_json
  end

  context "when lead providers don't match" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when valid user is an early_career_teacher" do
    %w[training-event-attended self-study-material-completed other].each do |evidence_held|
      it "creates a participant and profile declaration" do
        expect { described_class.call(ect_params.merge(evidence_held: evidence_held)) }.to change { ParticipantDeclaration.count }.by(1).and change { ProfileDeclaration.count }.by(1)
      end
    end

    it "fails when course is for mentor" do
      params = ect_params.merge({ course_identifier: "ecf-mentor" })
      params[:raw_event] = generate_raw_event(params)
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when user is not a participant" do
    it "does not create a declaration record and raises ParameterMissing for an invalid user_id" do
      expect { described_class.call(induction_coordinator_params) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when declaration type is invalid" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params.merge(declaration_type: "invalid")) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when evidence held is invalid" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params.merge(evidence_held: "invalid")) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when declaration date is invalid" do
    it "raises a ParameterMissing error" do
      params = ect_params.merge({ declaration_date: "2021-06-21 08:46:29" })
      params[:raw_event] = generate_raw_event(params)
      expected_msg = "param is missing or the value is empty: [\"The property '#/declaration_date' must be a valid RCF3339 date\"]"
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing, expected_msg)
    end
  end
end
