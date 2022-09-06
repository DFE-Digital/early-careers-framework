# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::ChangeSchedule::ECF, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let!(:profile)          { create(:ect, lead_provider: cpd_lead_provider.lead_provider) }
  let(:user)              { profile.user }

  describe "validations" do
    context "when null schedule_identifier given" do
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
      let(:original_schedule) { profile.schedule }
      let(:schedule)          { create(:ecf_schedule, name: "New Schedule", schedule_identifier: "new-schedule") }

      subject do
        described_class.new(
          params: {
            schedule_identifier: schedule.schedule_identifier,
            participant_id: user.id,
            course_identifier: "ecf-induction",
            cpd_lead_provider:,
          },
        )
      end

      it "should not have an error" do
        expect { subject.call }.not_to raise_error
      end

      it "updates the profile#schedule" do
        expect { subject.call }.to change { profile.reload.schedule }.from(original_schedule).to(schedule)
      end

      it "updates induction_record#schedule" do
        expect { subject.call }.to change { profile.current_induction_record.schedule }.from(original_schedule).to(schedule)
      end
    end

    context "when changing to schedule not suitable for the course" do
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
    let!(:declaration)      { create(:ect_participant_declaration, participant_profile: profile, cpd_lead_provider:) }
    let(:schedule)          { create(:schedule, :soft) }

    before do
      schedule
        .milestones
        .find_by!(declaration_type: declaration.declaration_type)
        .update!(start_date: declaration.declaration_date - 1.day)
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

    it "changes schedule" do
      expect {
        subject.call
      }.to change { profile.reload.schedule.schedule_identifier }.from("ecf-standard-september").to("soft-schedule")
    end
  end
end
