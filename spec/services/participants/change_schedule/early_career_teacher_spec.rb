# frozen_string_literal: true

require "rails_helper"

require_relative "../../../shared/context/lead_provider_profiles_and_courses"

RSpec.describe Participants::ChangeSchedule::EarlyCareerTeacher do
  include_context "lead provider profiles and courses"

  let(:participant_params) do
    {
      cpd_lead_provider: cpd_lead_provider,
      participant_id: ect_profile.user.id,
      course_identifier: "ecf-induction",
      schedule_identifier: "ecf-september-extended-2021",
    }
  end

  let!(:extended_schedule) { create(:schedule, schedule_identifier: "ecf-september-extended-2021") }

  context "when lead providers don't match" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params: participant_params.merge({ cpd_lead_provider: another_lead_provider })) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when valid user is an early_career_teacher" do
    it "changes the schedule on user's profile" do
      expect(ect_profile.reload.schedule.schedule_identifier).to eq("ecf-september-standard-2021")
      described_class.call(params: participant_params)
      expect(ect_profile.reload.schedule.schedule_identifier).to eq("ecf-september-extended-2021")
    end

    it "fails when the schedule is invalid" do
      params = participant_params.merge({ schedule_identifier: "wibble" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when the participant is withdrawn" do
      ParticipantProfileState.create!(participant_profile: ect_profile, state: "withdrawn")
      expect { described_class.call(params: participant_params) }
        .to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is for a mentor" do
      params = participant_params.merge({ course_identifier: "ecf-mentor" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is for an npq-course" do
      params = participant_params.merge({ course_identifier: "npq-leading-teacher" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when it would invalidate a non-voided declaration" do
      start_date = ect_profile.schedule.milestones.first.start_date
      declaration = create(:participant_declaration, declaration_date: start_date + 1.day, course_identifier: "ecf-induction", declaration_type: "started", cpd_lead_provider: cpd_lead_provider)
      create(:profile_declaration, participant_declaration: declaration, participant_profile: ect_profile)
      extended_schedule.milestones.each { |milestone| milestone.update!(start_date: milestone.start_date + 6.months, milestone_date: milestone.milestone_date + 6.months) }
      expect { described_class.call(params: participant_params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "changes the schedule on user's profile when it would invalidate a voided declaration" do
      start_date = ect_profile.schedule.milestones.first.start_date
      declaration = create(:participant_declaration, declaration_date: start_date + 1.day, course_identifier: "ecf-induction", declaration_type: "started", cpd_lead_provider: cpd_lead_provider)
      create(:profile_declaration, participant_declaration: declaration, participant_profile: ect_profile)
      declaration.void!
      extended_schedule.milestones.each { |milestone| milestone.update!(start_date: milestone.start_date + 6.months, milestone_date: milestone.milestone_date + 6.months) }

      described_class.call(params: participant_params)
      expect(ect_profile.reload.schedule.schedule_identifier).to eq("ecf-september-extended-2021")
    end
  end

  context "when user is not a participant" do
    it "raises ParameterMissing for an invalid user_id and not change participant profile state" do
      expect { described_class.call(params: participant_params.except(:participant_id)) }.to raise_error(ActionController::ParameterMissing).and(not_change { ParticipantProfileState.count })
    end
  end
end
