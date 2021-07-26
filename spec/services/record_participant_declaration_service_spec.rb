# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordParticipantDeclaration do
  let(:cpd_lead_provider) { create(:cpd_lead_provider) }
  let(:another_lead_provider) { create(:cpd_lead_provider, name: "Unknown") }
  let(:npq_lead_provider) { create(:npq_lead_provider, cpd_lead_provider: cpd_lead_provider) }
  let!(:npq_course) { create(:npq_course, identifier: "npq-leading-teaching") }
  let(:npq_profile) do
    create(:npq_validation_data,
           npq_lead_provider: npq_lead_provider,
           npq_course: npq_course)
  end
  let(:induction_coordinator_profile) { create(:induction_coordinator_profile) }
  let(:params) do
    {
      raw_event: "{\"participant_id\":\"37b300a8-4e99-49f1-ae16-0235672b6708\",\"declaration_type\":\"started\",\"declaration_date\":\"2021-06-21T08:57:31Z\",\"course_identifier\":\"npq-leading-teaching\"}",
      participant_id: npq_profile.user_id,
      declaration_date: "2021-06-21T08:46:29Z",
      declaration_type: "started",
      course_identifier: "npq-leading-teaching",
      cpd_lead_provider: another_lead_provider,
    }
  end

  context "when sending event for an npq course" do
    let(:npq_params) do
      params.merge({ cpd_lead_provider: cpd_lead_provider })
    end
    it "creates a participant and profile declaration" do
      expect { described_class.call(npq_params) }.to change { ParticipantDeclaration.count }.by(1).and change { ProfileDeclaration.count }.by(1)
    end
  end

  context "when sending event for an ect course" do
    let(:ect_profile) { create(:early_career_teacher_profile) }
    let(:mentor_profile) { create(:mentor_profile) }
    let(:ect_params) do
      params.merge({ cpd_lead_provider: cpd_lead_provider })
    end
    let(:mentor_params) do
      ect_params.merge({ participant_id: mentor_profile.user_id, course_identifier: "ecf-mentor" })
    end
    let(:induction_coordinator_params) do
      ect_params.merge({ participant_id: induction_coordinator_profile.user_id })
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
      it "creates a participant and profile declaration" do
        expect { described_class.call(ect_params) }.to change { ParticipantDeclaration.count }.by(1).and change { ProfileDeclaration.count }.by(1)
      end

      it "fails when course is for mentor" do
        params = ect_params.merge({ course_identifier: "ecf-mentor" })
        params[:raw_event] = generate_raw_event(params)
        expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when valid user is a mentor" do
      it "creates a participant and profile declaration" do
        expect { described_class.call(mentor_params) }.to change { ParticipantDeclaration.count }.by(1).and change { ProfileDeclaration.count }.by(1)
      end

      it "fails when course is for an early_career_teacher" do
        params = mentor_params.merge({ course_identifier: "ecf-induction" })
        params[:raw_event] = generate_raw_event(params)
        expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when user is not a participant" do
      it "does not create a declaration record and raises ParameterMissing for an invalid user_id" do
        expect { described_class.call(induction_coordinator_params) }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end
end
