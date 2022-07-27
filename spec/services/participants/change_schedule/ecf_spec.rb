# frozen_string_literal: true

require "rails_helper"
require "securerandom"

RSpec.describe Participants::ChangeSchedule::ECF do
  describe "validations" do
    context "when null schedule_identifier given" do
      let(:user) { profile.user }
      let(:profile) { create(:ecf_participant_profile) }

      subject do
        described_class.new(params: {
          schedule_identifier: nil,
          participant_id: user.id,
          course_identifier: "ecf-induction",
          cpd_lead_provider: CpdLeadProvider.new,
        })
      end

      before do
        create(:schedule, name: "Schedule with no alias")
      end

      it "should have an error" do
        expect { subject.call }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when changing to schedule suitable for the course" do
      let(:user) { profile.user }
      let(:profile) { create(:mentor_participant_profile) }
      let(:schedule) { create(:ecf_mentor_schedule) }
      let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:lead_provider) { cpd_lead_provider.lead_provider }
      let(:partnership) { create(:partnership, lead_provider:) }
      let(:induction_programme) { create(:induction_programme, :fip, partnership:) }

      before do
        Induction::Enrol.new(participant_profile: profile, induction_programme:).call
      end

      subject do
        described_class.new(params: {
          schedule_identifier: schedule.schedule_identifier,
          participant_id: user.id,
          course_identifier: "ecf-mentor",
          cpd_lead_provider:,
        })
      end

      it "should not have an error" do
        expect { subject.call }.not_to raise_error
      end
    end

    context "when changing to schedule not suitable for the course" do
      let(:user) { profile.user }
      let(:profile) { create(:ect_participant_profile) }
      let(:schedule) do
        create(:ecf_mentor_schedule)
      end

      subject do
        described_class.new(params: {
          schedule_identifier: schedule.schedule_identifier,
          participant_id: user.id,
          course_identifier: "ecf-induction",
          cpd_lead_provider: CpdLeadProvider.new,
        })
      end

      it "should have an error" do
        expect { subject.call }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when no identity found" do
      let(:schedule) { create(:ecf_schedule) }

      subject do
        described_class.new(params: {
          schedule_identifier: schedule.schedule_identifier,
          participant_id: SecureRandom.uuid,
          course_identifier: "ecf-induction",
          cpd_lead_provider: CpdLeadProvider.new,
        })
      end

      it "returns error with invalid participant_id" do
        expect { subject.call }.to raise_error(ActionController::ParameterMissing)
        expect(subject.errors.full_messages.join(",")).to include("Participant The property '#/participant_id' must be a valid Participant ID")
      end
    end
  end

  describe "changing to a soft schedules with previous declarations" do
    let(:cohort) { profile.schedule.cohort }
    let(:schedule) do
      Finance::Schedule.create!(
        cohort:,
        schedule_identifier: "soft-schedule",
        name: "soft-schedule",
      )
    end
    let!(:started_milestone) { create(:milestone, :started, :soft_milestone, schedule:) }
    let(:user) { profile.user }
    let(:profile) { create(:ect_participant_profile) }
    let!(:declaration) do
      create(:participant_declaration,
             user:,
             participant_profile: profile,
             course_identifier: "ecf-induction")
    end

    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:lead_provider) { cpd_lead_provider.lead_provider }
    let(:partnership) { create(:partnership, lead_provider:) }
    let(:induction_programme) { create(:induction_programme, :fip, partnership:) }

    before do
      Induction::Enrol.new(participant_profile: profile, induction_programme:).call
    end

    subject do
      described_class.new(params: {
        schedule_identifier: schedule.schedule_identifier,
        participant_id: user.id,
        course_identifier: "ecf-induction",
        cpd_lead_provider:,
        cohort: schedule.cohort.start_year,
      })
    end

    it "create a new induction record with new schedule" do
      expect {
        subject.call
      }.to change { InductionRecord.count }.by(1)

      new_induction_record = InductionRecord.order(created_at: :asc).last

      expect(new_induction_record.schedule).to eql(schedule)
    end

    it "also updates the schedule on the profile" do
      expect {
        subject.call
      }.to change { profile.reload.schedule.schedule_identifier }.from("ecf-standard-september").to("soft-schedule")
    end
  end

  describe "when one profile and 2 induction records, where profile#training_status is withdrawn" do
    let(:user) { profile.user }
    let(:profile) { create(:ect_participant_profile, status: "active", training_status: "withdrawn") }
    let(:new_schedule) { create(:ecf_schedule, schedule_identifier: "new-schedule") }

    let(:induction_programme_1) { create(:induction_programme, :fip)  }
    let(:induction_programme_2) { create(:induction_programme, :fip)  }

    let!(:induction_record_1) do
      create(
        :induction_record,
        participant_profile: profile,
        induction_programme: induction_programme_1,
      )
    end

    let!(:induction_record_2) do
      create(
        :induction_record,
        participant_profile: profile,
        induction_programme: induction_programme_2,
      )
    end

    let(:cpd_lead_provider_1) { induction_record_1.induction_programme.partnership.lead_provider.cpd_lead_provider }
    let(:cpd_lead_provider_2) { induction_record_2.induction_programme.partnership.lead_provider.cpd_lead_provider }

    before do
      profile.participant_profile_states.create!(state: "withdrawn")
    end

    subject do
      described_class.new(params: {
        schedule_identifier: new_schedule.schedule_identifier,
        participant_id: user.id,
        course_identifier: "ecf-induction",
        cpd_lead_provider: cpd_lead_provider_2,
      })
    end

    it "creates a new induction record with new schedule" do
      expect {
        subject.call
      }.to change { InductionRecord.count }.by(1)

      new_induction_record = InductionRecord.order(created_at: :asc).last

      expect(new_induction_record.schedule).to eql(new_schedule)
    end
  end

  describe "changing schedule in a different cohort" do
    let(:user) { profile.user }
    let(:profile) { create(:ect_participant_profile) }

    let(:cohort) { profile.schedule.cohort }
    let(:cohort_year) { cohort.start_year }
    let(:next_cohort) { Cohort.find_by(start_year: (cohort_year + 1)) || create(:cohort, start_year: (cohort_year + 1)) }

    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:lead_provider) { cpd_lead_provider.lead_provider }
    let(:partnership) { create(:partnership, lead_provider:) }
    let(:induction_programme) { create(:induction_programme, :fip, partnership:) }

    let(:new_schedule) { create(:ecf_schedule, cohort: next_cohort, schedule_identifier: "new-schedule") }

    before do
      Induction::Enrol.new(participant_profile: profile, induction_programme:).call
    end

    subject do
      described_class.new(params: {
        schedule_identifier: new_schedule.schedule_identifier,
        participant_id: user.id,
        course_identifier: "ecf-induction",
        cpd_lead_provider:,
        cohort: cohort_year + 1,
      })
    end

    it "does not change schedule as not permitted" do
      expect {
        subject.call
      }.to raise_error(ActionController::ParameterMissing, /The property '#\/cohort' cannot be changed/)
       .and not_change { InductionRecord.count }
    end
  end

  describe "changing schedule when induction record is withdrawn" do
    let(:user) { profile.user }
    let(:profile) { create(:ect_participant_profile) }

    let(:cohort) { profile.schedule.cohort }

    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:lead_provider) { cpd_lead_provider.lead_provider }
    let(:partnership) { create(:partnership, lead_provider:) }
    let(:induction_programme) { create(:induction_programme, :fip, partnership:) }

    let(:new_schedule) { create(:ecf_schedule, cohort:, schedule_identifier: "new-schedule") }

    before do
      Induction::Enrol.new(participant_profile: profile, induction_programme:).call.tap do |ir|
        ir.update!(training_status: "withdrawn", induction_status: "withdrawn")
      end
    end

    subject do
      described_class.new(params: {
        schedule_identifier: new_schedule.schedule_identifier,
        participant_id: user.id,
        course_identifier: "ecf-induction",
        cpd_lead_provider:,
        cohort: cohort.start_year,
      })
    end

    it "does not change schedule as not permitted" do
      expect {
        subject.call
      }.to raise_error(ActionController::ParameterMissing, /Cannot perform actions on a withdrawn participant/)
       .and not_change { InductionRecord.count }
    end
  end

  describe "changing schedule when hard awaiting_clawback declaration present" do
    let(:cohort) { profile.schedule.cohort }
    let(:new_schedule) { create(:ecf_schedule, cohort:, schedule_identifier: "new-schedule") }

    let(:user) { profile.user }
    let(:profile) { create(:ect_participant_profile) }

    let!(:declaration) do
      create(
        :participant_declaration,
        user:,
        participant_profile: profile,
        course_identifier: "ecf-induction",
        state: "awaiting_clawback",
      )
    end

    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:lead_provider) { cpd_lead_provider.lead_provider }
    let(:partnership) { create(:partnership, lead_provider:) }
    let(:induction_programme) { create(:induction_programme, :fip, partnership:) }

    before do
      Induction::Enrol.new(participant_profile: profile, induction_programme:).call
    end

    subject do
      described_class.new(params: {
        schedule_identifier: new_schedule.schedule_identifier,
        participant_id: user.id,
        course_identifier: "ecf-induction",
        cpd_lead_provider:,
        cohort: cohort.start_year,
      })
    end

    it "creates a new induction record with new schedule" do
      expect {
        subject.call
      }.to change { InductionRecord.count }.by(1)

      new_induction_record = InductionRecord.order(created_at: :asc).last

      expect(new_induction_record.schedule).to eql(new_schedule)
    end

    it "also changes schedule on the profile" do
      expect {
        subject.call
      }.to change { profile.reload.schedule.schedule_identifier }.from("ecf-standard-september").to("new-schedule")
    end
  end

  describe "changing schedule when hard paid declaration present" do
    let(:cohort) { profile.schedule.cohort }
    let(:new_schedule) { create(:ecf_schedule, cohort:, schedule_identifier: "new-schedule") }

    let(:user) { profile.user }
    let(:profile) { create(:ect_participant_profile) }

    let!(:declaration) do
      create(
        :participant_declaration,
        user:,
        participant_profile: profile,
        course_identifier: "ecf-induction",
        state: "paid",
      )
    end

    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:lead_provider) { cpd_lead_provider.lead_provider }
    let(:partnership) { create(:partnership, lead_provider:) }
    let(:induction_programme) { create(:induction_programme, :fip, partnership:) }

    before do
      Induction::Enrol.new(participant_profile: profile, induction_programme:).call
    end

    subject do
      described_class.new(params: {
        schedule_identifier: new_schedule.schedule_identifier,
        participant_id: user.id,
        course_identifier: "ecf-induction",
        cpd_lead_provider:,
        cohort: cohort.start_year,
      })
    end

    it "does not change schedule" do
      expect {
        subject.call
      }.to raise_error(ActionController::ParameterMissing, /Changing schedule would invalidate existing declarations. Please void them first./)
       .and not_change { InductionRecord.count }
    end
  end

  context "when there are multiple induction records for same provider" do
    let(:user) { profile.user }
    let(:profile) { create(:ect_participant_profile) }
    let(:schedule) { create(:ecf_schedule) }
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:lead_provider) { cpd_lead_provider.lead_provider }
    let(:partnership) { create(:partnership, lead_provider:) }
    let(:induction_programme) { create(:induction_programme, :fip, partnership:) }
    let(:mentor_profile) { create(:mentor_participant_profile) }

    let(:first_induction_record) { Induction::Enrol.new(participant_profile: profile, induction_programme:).call }

    before do
      Induction::ChangeMentor.call(induction_record: first_induction_record, mentor_profile:)
    end

    subject do
      described_class.new(params: {
        schedule_identifier: schedule.schedule_identifier,
        participant_id: user.id,
        course_identifier: "ecf-induction",
        cpd_lead_provider:,
      })
    end

    it "creates a new induction record" do
      expect { subject.call }.to change { InductionRecord.count }.by(1)
    end

    it "bases new induction record from correct induction record" do
      subject.call

      new_induction_record = InductionRecord.order(created_at: :asc).last

      expect(new_induction_record.mentor_profile).to eql(mentor_profile)
    end
  end
end
