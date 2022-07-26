# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::ChangeSchedule::ECF do
  describe "validations" do
    context "when null schedule_identifier given" do
      let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:lead_provider) { cpd_lead_provider.lead_provider }
      let(:user) { profile.user }
      let(:profile) { create(:ect_participant_profile, school_cohort:) }
      let(:school_cohort) { create(:school_cohort) }
      let(:school) { school_cohort.school }
      let!(:partnership) { create(:partnership, school:, lead_provider:, cohort: school_cohort.cohort) }
      let(:schedule) { create(:ecf_schedule) }

      subject do
        described_class.new(params: {
          schedule_identifier: nil,
          participant_id: user.id,
          course_identifier: "ecf-induction",
          cpd_lead_provider:,
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
      let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:lead_provider) { cpd_lead_provider.lead_provider }
      let(:user) { profile.user }
      let(:profile) { create(:ect_participant_profile, school_cohort:) }
      let(:school_cohort) { create(:school_cohort) }
      let(:school) { school_cohort.school }
      let!(:partnership) { create(:partnership, school:, lead_provider:, cohort: school_cohort.cohort) }
      let(:original_schedule) { profile.schedule }
      let(:schedule) { create(:ecf_schedule, schedule_identifier: "new-schedule") }
      let!(:induction_record) do
        create(
          :induction_record,
          participant_profile: profile,
          schedule: original_schedule,
          induction_programme:,
        )
      end
      let(:induction_programme) do
        create(
          :induction_programme,
          :fip,
          school_cohort:,
          partnership:,
        )
      end

      subject do
        described_class.new(params: {
          schedule_identifier: schedule.schedule_identifier,
          participant_id: user.id,
          course_identifier: "ecf-induction",
          cpd_lead_provider:,
        })
      end

      it "should not have an error" do
        expect { subject.call }.not_to raise_error
      end

      it "updates the profile#schedule" do
        expect { subject.call }.to change { profile.reload.schedule }.from(original_schedule).to(schedule)
      end

      it "updates induction_record#schedule" do
        expect { subject.call }.to change { induction_record.reload.schedule }.from(original_schedule).to(schedule)
      end
    end

    context "when changing to schedule not suitable for the course" do
      let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:lead_provider) { cpd_lead_provider.lead_provider }
      let(:user) { profile.user }
      let(:profile) { create(:ect_participant_profile, school_cohort:) }
      let(:school_cohort) { create(:school_cohort) }
      let(:school) { school_cohort.school }
      let!(:partnership) { create(:partnership, school:, lead_provider:, cohort: school_cohort.cohort) }
      let(:schedule) { create(:ecf_mentor_schedule) }

      subject do
        described_class.new(params: {
          schedule_identifier: schedule.schedule_identifier,
          participant_id: user.id,
          course_identifier: "ecf-induction",
          cpd_lead_provider:,
        })
      end

      it "should have an error" do
        expect { subject.call }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end

  describe "changing to a soft schedules with previous declarations" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:lead_provider) { cpd_lead_provider.lead_provider }
    let(:user) { profile.user }
    let(:profile) { create(:ect_participant_profile, school_cohort:) }
    let(:school_cohort) { create(:school_cohort) }
    let(:cohort) { school_cohort.cohort }
    let(:school) { school_cohort.school }
    let!(:partnership) { create(:partnership, school:, lead_provider:, cohort: school_cohort.cohort) }
    let(:schedule) { create(:ecf_mentor_schedule) }

    let(:schedule) do
      create(:schedule, cohort:, schedule_identifier: "soft-schedule", name: "soft-schdule")
    end

    let!(:started_milestone) { create(:milestone, :started, :soft_milestone, schedule:) }
    let!(:declaration) do
      create(:participant_declaration,
             user:,
             participant_profile: profile,
             course_identifier: "ecf-induction")
    end

    let(:induction_programme) do
      create(
        :induction_programme,
        :fip,
        school_cohort:,
        partnership:,
      )
    end
    let!(:induction_record) { Induction::Enrol.call(participant_profile: profile, induction_programme:) }

    subject do
      described_class.new(params: {
        schedule_identifier: schedule.schedule_identifier,
        participant_id: user.id,
        course_identifier: "ecf-induction",
        cpd_lead_provider:,
        cohort: schedule.cohort.start_year,
      })
    end

    it "changes schedule" do
      expect {
        subject.call
      }.to change { profile.reload.schedule.schedule_identifier }.from("ecf-standard-september").to("soft-schedule")
    end
  end
end
