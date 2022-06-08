# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordParticipantDeclaration do
  context "when sending event for an npq course" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
    let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
    let(:npq_application) { create(:npq_application, npq_lead_provider:) }
    let(:profile) { create(:npq_participant_profile, npq_application:) }
    let(:user) { profile.user }
    let(:npq_course) { profile.npq_course }
    let(:declaration_date) { profile.schedule.milestones.where(declaration_type: "started").first.start_date + 3.days }

    let(:params) do
      {
        participant_id: user.id,
        declaration_date: declaration_date.rfc3339,
        declaration_type: "started",
        course_identifier: npq_course.identifier,
        cpd_lead_provider:,
      }
    end

    before do
      create(:npq_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider:)
    end

    it "creates a participant declaration" do
      expect { described_class.call(params) }.to change { ParticipantDeclaration.count }.by(1)
    end

    context "when the npq application is eligible for funding" do
      before do
        profile.npq_application.update!(eligible_for_funding: true)
      end

      it "creates the participant declaration in the eligible state" do
        described_class.call(params)
        declaration = profile.participant_declarations.first
        expect(declaration.state).to eql("eligible")
      end
    end

    context "when the npq application is not eligible for funding" do
      before do
        profile.npq_application.update!(eligible_for_funding: false)
      end

      it "creates the participant declaration in the submitted state" do
        described_class.call(params)
        declaration = profile.participant_declarations.first
        expect(declaration.state).to eql("submitted")
      end
    end
  end

  context "when sending event for an ect course" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:lead_provider) { cpd_lead_provider.lead_provider }
    let(:profile) { create(:ect_participant_profile) }
    let(:user) { profile.user }
    let(:school) { profile.school_cohort.school }
    let(:cohort) { profile.school_cohort.cohort }

    let(:induction_programme) { create(:induction_programme, partnership:) }

    let!(:induction_record) do
      Induction::Enrol.call(participant_profile: profile, induction_programme:)
    end

    let!(:partnership) do
      create(
        :partnership,
        school:,
        lead_provider:,
        cohort:,
      )
    end

    let(:declaration_date) { profile.schedule.milestones.where(declaration_type: "started").first.start_date + 5.days }

    let(:params) do
      {
        participant_id: user.id,
        declaration_date: declaration_date.rfc3339,
        declaration_type: "started",
        course_identifier: "ecf-induction",
        cpd_lead_provider:,
      }
    end

    before do
      travel_to profile.schedule.milestones.where(declaration_type: "started").first.start_date + 10.days
    end

    context "happy path" do
      it "persists the declaration" do
        expect {
          described_class.call(params)
        }.to change(ParticipantDeclaration::ECF, :count).by(1)
      end
    end

    context "when a voided payable declaration exists" do
      before do
        profile.participant_declarations.create!(
          cpd_lead_provider:,
          course_identifier: "ecf-induction",
          user:,
          declaration_date: profile.schedule.milestones.where(declaration_type: "started").first.start_date + 3.days,
          declaration_type: "started",
          state: "voided",
        )
      end

      it "can re-submit the same declaration later" do
        expect { described_class.call(params) }.to change { ParticipantDeclaration.count }.by(1)
      end
    end

    context "when lead providers don't match" do
      let(:other_cpd_lead_provider) { create(:cpd_lead_provider) }

      let(:params) do
        {
          participant_id: user.id,
          declaration_date: declaration_date.rfc3339,
          declaration_type: "started",
          course_identifier: "ecf-induction",
          cpd_lead_provider: other_cpd_lead_provider,
        }
      end

      it "raises a ParameterMissing error" do
        expect {
          described_class.call(params)
        }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when incorrect course given" do
      let(:params) do
        {
          participant_id: user.id,
          declaration_date: declaration_date.rfc3339,
          declaration_type: "started",
          course_identifier: "ecf-mentor",
          cpd_lead_provider:,
        }
      end

      it "fails when course is for mentor" do
        expect {
          described_class.call(params)
        }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when valid user is a mentor" do
      let(:profile) { create(:mentor_participant_profile) }

      let(:params) do
        {
          participant_id: user.id,
          declaration_date: declaration_date.rfc3339,
          declaration_type: "started",
          course_identifier: "ecf-mentor",
          cpd_lead_provider:,
        }
      end

      it "creates a participant and profile declaration" do
        expect {
          described_class.call(params)
        }.to change { ParticipantDeclaration.count }.by(1)
      end

      context "when incorrect course given" do
        let(:params) do
          {
            participant_id: user.id,
            declaration_date: declaration_date.rfc3339,
            declaration_type: "started",
            course_identifier: "ecf-induction",
            cpd_lead_provider:,
          }
        end

        it "fails when course is for an early_career_teacher" do
          expect {
            described_class.call(params)
          }.to raise_error(ActionController::ParameterMissing)
        end
      end
    end

    context "when user is not a participant" do
      let(:params) do
        {
          participant_id: SecureRandom.uuid,
          declaration_date: declaration_date.rfc3339,
          declaration_type: "started",
          course_identifier: "ecf-induction",
          cpd_lead_provider:,
        }
      end

      it "does not create a declaration record and raises ParameterMissing for an invalid user_id" do
        expect {
          described_class.call(params)
        }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end
end
