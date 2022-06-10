# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::ChangeSchedule::NPQ, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:profile)           { create(:npq_participant_profile, npq_lead_provider: cpd_lead_provider.npq_lead_provider) }
  let(:user)              { profile.user }
  let(:schedule) do
    NPQCourse.schedule_for(npq_course: profile.npq_course)
  end

  describe "validations" do
    context "when null schedule_identifier given" do
      subject do
        described_class.new(params: {
          schedule_identifier: nil,
          participant_id: user.id,
          course_identifier: profile.npq_course.identifier,
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
      subject do
        described_class.new(params: {
          schedule_identifier: schedule.schedule_identifier,
          participant_id: user.id,
          course_identifier: profile.npq_course.identifier,
          cpd_lead_provider:,
        })
      end

      it "should not have an error" do
        expect { subject.call }.not_to raise_error
      end
    end

    context "when changing to schedule not suitable for the course" do
      let(:schedule) { create(:ecf_mentor_schedule) }

      subject do
        described_class.new(params: {
          schedule_identifier: schedule.schedule_identifier,
          participant_id: user.id,
          course_identifier: profile.npq_course.identifier,
          cpd_lead_provider:,
        })
      end

      it "should have an error" do
        expect { subject.call }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end

  describe "changing to a soft schedules with previous declarations", :with_default_schedules do
    let!(:declaration) do
      create(
        :npq_participant_declaration,
        participant_profile: profile,
        course_identifier: profile.npq_course.identifier,
        declaration_date: schedule.milestones.find_by(declaration_type: "started").start_date + 1.day,
      )
    end
    let(:cohort) { create(:cohort, :next) }
    let(:schedule) do
      case profile.npq_course.identifier
      when *Finance::Schedule::NPQSpecialist::IDENTIFIERS
        create(:npq_specialist_schedule, :soft, cohort:)
      when *Finance::Schedule::NPQLeadership::IDENTIFIERS
        create(:npq_leadership_schedule,  :soft, cohort:)
      when *Finance::Schedule::NPQSupport::IDENTIFIERS
        create(:npq_aso_schedule, :soft, cohort:)
      when *Finance::Schedule::NPQEhco::IDENTIFIERS
        create(:npq_ehco_schedule, :soft, cohort:)
      end
    end

    subject do
      described_class.new(params: {
        schedule_identifier: schedule.schedule_identifier,
        participant_id: user.id,
        course_identifier: profile.npq_course.identifier,
        cpd_lead_provider:,
        cohort: schedule.cohort.start_year,
      })
    end

    it "changes schedule" do
      expect {
        subject.call
      }.to change { profile.reload.schedule.schedule_identifier }.from(profile.schedule.schedule_identifier).to("soft-schedule")
    end
  end
end
