# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordParticipantDeclaration do
  let(:ecf_lead_provider) { create(:lead_provider) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider: ecf_lead_provider) }
  let(:another_cpd_lead_provider) { create(:cpd_lead_provider, name: "Unknown") }
  let(:npq_lead_provider) { create(:npq_lead_provider, cpd_lead_provider: cpd_lead_provider) }

  let(:user) { create(:user) }
  let(:teacher_profile) { create(:teacher_profile, user: user) }
  let(:induction_coordinator_profile) { create(:induction_coordinator_profile) }

  context "when sending event for an npq course" do
    let(:npq_course) { create(:npq_course, identifier: "npq-leading-teaching") }

    let(:npq_validation_data) do
      create(:npq_validation_data,
             npq_lead_provider: npq_lead_provider,
             npq_course: npq_course,
             user: user)
    end

    let(:params) do
      {
        user_id: user.id,
        declaration_date: "2021-06-21T08:46:29Z",
        declaration_type: "started",
        course_identifier: "npq-leading-teaching",
        lead_provider_from_token: cpd_lead_provider,
      }
    end

    let!(:npq_participant_profile) { create(:participant_profile, :npq, teacher_profile: teacher_profile, validation_data: npq_validation_data) }

    it "creates a participant and profile declaration" do
      expect { described_class.call(params) }.to change { ParticipantDeclaration.count }.by(1).and change { ProfileDeclaration.count }.by(1)
    end
  end

  context "when sending event for an ect course" do
    let(:params) do
      {
        user_id: user.id,
        declaration_date: "2021-06-21T08:46:29Z",
        declaration_type: "started",
        course_identifier: "ecf-induction",
        lead_provider_from_token: cpd_lead_provider,
      }
    end

    let(:delivery_partner) { create(:delivery_partner) }

    let(:school_cohort) { create(:school_cohort, school: profile.school, cohort: profile.cohort) }

    let(:partnership) do
      create(:partnership,
             school: profile.school,
             lead_provider: cpd_lead_provider.lead_provider,
             cohort: profile.cohort,
             delivery_partner: delivery_partner)
    end

    context "when lead providers don't match" do
      before do
        params[:lead_provider_from_token] = another_cpd_lead_provider
      end

      it "raises a ParameterMissing error" do
        expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when valid user is an early_career_teacher" do
      before do
        school_cohort
        partnership
      end

      let(:profile) { create(:early_career_teacher_profile, teacher_profile: teacher_profile) }

      it "creates a participant and profile declaration" do
        expect { described_class.call(params) }.to change { ParticipantDeclaration.count }.by(1).and change { ProfileDeclaration.count }.by(1)
      end

      it "fails when course is for mentor" do
        params.merge!({ course_identifier: "ecf-mentor" })
        expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when valid user is a mentor" do
      before do
        school_cohort
        partnership
      end

      let(:profile) { create(:mentor_profile, teacher_profile: teacher_profile) }

      let(:mentor_params) do
        params.merge({ user_id: profile.user.id, course_identifier: "ecf-mentor" })
      end

      it "creates a participant and profile declaration" do
        expect { described_class.call(mentor_params) }.to change { ParticipantDeclaration.count }.by(1).and change { ProfileDeclaration.count }.by(1)
      end

      it "fails when course is for an early_career_teacher" do
        params = mentor_params.merge({ course_identifier: "ecf-induction" })

        expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when user is not a participant" do
      let(:induction_coordinator_params) do
        params.merge({ user_id: induction_coordinator_profile.user_id })
      end

      it "does not create a declaration record and raises ParameterMissing for an invalid user_id" do
        expect { described_class.call(induction_coordinator_params) }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end
end
