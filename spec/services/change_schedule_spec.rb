# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "validating a participant for a change schedule" do
  context "when the schedule is missing" do
    let(:schedule_identifier) {}

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:schedule_identifier)).to include("The property '#/schedule_identifier' must be present and correspond to a valid schedule")
    end
  end

  context "when the course identifier is missing" do
    let(:course_identifier) {}

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:course_identifier)).to include("The property '#/course_identifier' must be an available course to '#/participant_id'")
    end
  end

  context "when the course identifier is an invalid value" do
    let(:course_identifier) { "invalid-value" }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:course_identifier)).to include("The property '#/course_identifier' must be an available course to '#/participant_id'")
    end
  end

  context "when the participant identifier is missing" do
    let(:participant_id) {}

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:participant_id)).to include("The property '#/participant_id' must be a valid Participant ID")
    end
  end

  context "when the participant identifier is an invalid value" do
    let(:participant_id) { "invalid-value" }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:participant_id)).to include("The property '#/participant_id' must be a valid Participant ID")
    end
  end

  context "when the participant does not belong to the CPD lead provider" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:participant_id)).to include("The property '#/participant_id' must be a valid Participant ID")
    end
  end
end

RSpec.shared_examples "validating a participant is not already withdrawn" do
  it "is invalid and returns an error message" do
    is_expected.to be_invalid

    expect(service.errors.messages_for(:participant_id)).to include("Cannot perform actions on a withdrawn participant")
  end
end

RSpec.shared_examples "changing the schedule of a participant" do
  context "when invalid" do
    let(:params) {}
    it "does not create a new participant profile schedule" do
      expect { service.call }.not_to change { ParticipantProfileSchedule.count }
    end

    it "does not create a new induction record" do
      expect { service.call }.not_to change { InductionRecord.count }
    end
  end

  it "creates a participant profile schedule" do
    expect { service.call }.to change { ParticipantProfileSchedule.count }
  end

  it "sets the correct attributes to the new participant profile schedule" do
    service.call
    latest_participant_profile_schedule = participant_profile.participant_profile_schedules.last

    expect(latest_participant_profile_schedule).to have_attributes(
      participant_profile_id: participant_profile.id,
      schedule_id: Finance::Schedule.where(schedule_identifier:, cohort: Cohort.current).first.id,
    )
  end
end

RSpec.describe ChangeSchedule, :with_default_schedules do
  let(:participant_id) { participant_profile.participant_identity.external_identifier }
  let(:induction_record) { participant_profile.induction_records.first }
  let(:params) do
    {
      cpd_lead_provider:,
      participant_id:,
      course_identifier:,
      schedule_identifier:,
    }
  end

  subject(:service) do
    described_class.new(params)
  end

  context "ECT participant profile" do
    let(:cpd_lead_provider) { induction_record.cpd_lead_provider }
    let(:schedule_identifier) { "ecf-standard-september" }
    let(:schedule) { create(:schedule, schedule_identifier:, name: "ECF Standard") }
    let(:participant_profile) { create(:ect) }
    let(:course_identifier) { "ecf-induction" }

    describe "validations" do
      it_behaves_like "validating a participant for a change schedule"

      it_behaves_like "validating a participant is not already withdrawn" do
        let(:participant_profile) { create(:ect, :withdrawn) }
      end
    end

    describe ".call" do
      it_behaves_like "changing the schedule of a participant"
    end
  end

  context "Mentor participant profile" do
    let(:cpd_lead_provider) { induction_record.cpd_lead_provider }
    let(:schedule_identifier) { "ecf-standard-september" }
    let(:schedule) { create(:schedule, schedule_identifier:, name: "ECF Standard") }
    let(:participant_profile) { create(:mentor) }
    let(:course_identifier) { "ecf-mentor" }

    describe "validations" do
      it_behaves_like "validating a participant for a change schedule"

      it_behaves_like "validating a participant is not already withdrawn" do
        let(:participant_profile) { create(:mentor, :withdrawn) }
      end
    end

    describe ".call" do
      it_behaves_like "changing the schedule of a participant"
    end
  end

  context "NPQ participant profile" do
    let(:cpd_lead_provider) { npq_application.npq_lead_provider.cpd_lead_provider }
    let(:schedule_identifier) { "npq-leadership-spring" }
    let(:schedule) { create(:schedule, schedule_identifier:, name: "NPQ Standard") }
    let(:npq_application) { create(:npq_application, :accepted, npq_course: create(:npq_course, identifier: "npq-senior-leadership")) }
    let(:participant_profile) { npq_application.profile }
    let!(:course_identifier) { npq_application.npq_course.identifier }

    describe "validations" do
      it_behaves_like "validating a participant for a change schedule"

      it_behaves_like "validating a participant is not already withdrawn" do
        let(:participant_profile) { create(:npq_participant_profile, :withdrawn, npq_application:) }
      end
    end

    describe ".call" do
      it_behaves_like "changing the schedule of a participant"
    end
  end
end
