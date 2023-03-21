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
    let(:another_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
    let(:npq_lead_provider) { another_cpd_lead_provider.npq_lead_provider }
    let(:participant_profile) { create(:npq_participant_profile, npq_lead_provider:) }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:participant_id)).to include("The property '#/participant_id' must be a valid Participant ID")
    end
  end

  context "when the schedule identifier change of the same type again" do
    before { described_class.new(params).call }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:schedule_identifier)).to include("Selected schedule is already on the profile")
    end
  end

  context "when the participant has a different user ID to external ID" do
    let(:participant_identity) { create(:participant_identity, :secondary) }

    before { participant_profile.update!(participant_identity:) }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:participant_id)).to include("The property '#/participant_id' must be a valid Participant ID")
    end
  end
end

RSpec.shared_examples "validating a participant is not already withdrawn for a change schedule" do
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
      schedule_id: Finance::Schedule.where(schedule_identifier:, cohort: new_cohort).first.id,
    )
  end
end

RSpec.describe ChangeSchedule, :with_default_schedules, with_feature_flags: { external_identifier_to_user_id_lookup: "active" } do
  let(:participant_id) { participant_profile.participant_identity.external_identifier }
  let(:params) do
    {
      cpd_lead_provider:,
      participant_id:,
      course_identifier:,
      schedule_identifier:,
    }
  end
  let(:new_cohort) { Cohort.current }

  subject(:service) do
    described_class.new(params)
  end

  context "ECT participant profile" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:participant_profile) { create(:ect, lead_provider: cpd_lead_provider.lead_provider) }
    let(:schedule_identifier) { "ecf-extended-april" }
    let(:course_identifier) { "ecf-induction" }
    let!(:schedule) { create(:ecf_schedule, schedule_identifier: "ecf-extended-april", name: "ECF Standard") }

    describe "validations" do
      it_behaves_like "validating a participant for a change schedule"

      it_behaves_like "validating a participant is not already withdrawn for a change schedule" do
        let(:participant_profile) { create(:ect, :withdrawn, lead_provider: cpd_lead_provider.lead_provider) }
      end
    end

    describe ".call" do
      it_behaves_like "changing the schedule of a participant"

      it "updates the schedule on the relevant induction record" do
        service.call
        relevant_induction_record = participant_profile.current_induction_record

        expect(relevant_induction_record.schedule).to eq(schedule)
      end

      context "when profile schedule is not the same as the induction record" do
        let(:participant_profile) { create(:ect, lead_provider: cpd_lead_provider.lead_provider, schedule:) }

        it "updates the schedule on the relevant induction record" do
          service.call
          relevant_induction_record = participant_profile.current_induction_record

          expect(relevant_induction_record.schedule).to eq(schedule)
        end
      end
    end
  end

  context "Mentor participant profile" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:participant_profile) { create(:mentor, lead_provider: cpd_lead_provider.lead_provider) }
    let(:schedule_identifier) { "ecf-extended-april" }
    let(:course_identifier) { "ecf-mentor" }
    let!(:schedule) { create(:ecf_mentor_schedule, schedule_identifier: "ecf-extended-april", name: "Mentor Standard") }

    describe "validations" do
      it_behaves_like "validating a participant for a change schedule"

      it_behaves_like "validating a participant is not already withdrawn for a change schedule" do
        let(:participant_profile) { create(:mentor, :withdrawn, lead_provider: cpd_lead_provider.lead_provider) }
      end
    end

    describe ".call" do
      it_behaves_like "changing the schedule of a participant"

      it "updates the schedule on the relevant induction record" do
        service.call
        relevant_induction_record = participant_profile.current_induction_record

        expect(relevant_induction_record.schedule).to eq(schedule)
      end

      context "when profile schedule is not the same as the induction record" do
        before { participant_profile.update!(schedule:) }

        it "updates the schedule on the relevant induction record" do
          service.call
          relevant_induction_record = participant_profile.current_induction_record

          expect(relevant_induction_record.schedule).to eq(schedule)
        end
      end
    end
  end

  context "NPQ participant profile" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
    let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
    let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
    let(:schedule) { create(:npq_specialist_schedule) }
    let(:participant_profile) { create(:npq_participant_profile, npq_lead_provider:, npq_course:, schedule:) }
    let(:course_identifier) { npq_course.identifier }
    let(:schedule_identifier) { new_schedule.schedule_identifier }
    let(:new_schedule) { create(:npq_leadership_schedule) }

    describe "validations" do
      it_behaves_like "validating a participant for a change schedule"

      it_behaves_like "validating a participant is not already withdrawn for a change schedule" do
        let(:participant_profile) { create(:npq_participant_profile, :withdrawn, npq_lead_provider:, npq_course:) }
      end
    end

    describe ".call" do
      it_behaves_like "changing the schedule of a participant"

      it "does not update the npq application cohort" do
        expect { service.call }.not_to change(participant_profile.npq_application, :cohort)
      end
    end

    context "when cohort is changed" do
      let(:new_cohort) { Cohort.previous }
      let(:new_schedule) { create(:npq_leadership_schedule, cohort: new_cohort) }
      let(:params) do
        {
          cpd_lead_provider:,
          participant_id:,
          course_identifier:,
          schedule_identifier:,
          cohort: new_cohort.start_year,
        }
      end

      describe ".call" do
        it_behaves_like "changing the schedule of a participant"
      end

      it "updates the cohort on the npq application" do
        service.call
        expect(participant_profile.npq_application.cohort).to eq(new_cohort)
      end
    end
  end
end
