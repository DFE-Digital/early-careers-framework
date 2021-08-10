# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Started::EarlyCareerTeacher do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider: create(:lead_provider)) }
  let(:another_lead_provider) { create(:cpd_lead_provider, name: "Unknown", lead_provider: create(:lead_provider)) }
  let(:ect_profile) { create(:participant_profile, :ect) }
  let(:mentor_profile) { create(:participant_profile, :mentor) }
  let(:induction_coordinator_profile) { create(:induction_coordinator_profile) }
  let(:params) do
    {
      user_id: ect_profile.user.id,
      declaration_date: "2021-06-21T08:46:29Z",
      declaration_type: "started",
      course_identifier: "ecf-induction",
      lead_provider_from_token: another_lead_provider,
    }
  end
  let(:ect_params) do
    params.merge({ lead_provider_from_token: cpd_lead_provider })
  end
  let(:mentor_params) do
    ect_params.merge({ user_id: mentor_profile.user_id, course_identifier: "ecf-mentor" })
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

  context "when lead providers don't match" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when valid user is an early_career_teacher" do
    it "creates a participant and profile declaration" do
      expect { described_class.call(ect_params) }.to change { ParticipantDeclaration.count }.by(1).and change { ProfileDeclaration.count }.by(1)
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
end
