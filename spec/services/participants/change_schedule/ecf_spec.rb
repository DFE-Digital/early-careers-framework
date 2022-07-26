# frozen_string_literal: true

require "rails_helper"
require "securerandom"

RSpec.describe Participants::ChangeSchedule::ECF do
  let(:klass) do
    Class.new(described_class) do
      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      def self.valid_courses
        %w[ecf-induction ecf-mentor]
      end

      def user_profile
        User.find(participant_id).participant_profiles[0]
      end

      def matches_lead_provider?
        true
      end
    end
  end

  describe "validations" do
    context "when null schedule_identifier given" do
      let(:user) { profile.user }
      let(:profile) { create(:ecf_participant_profile) }

      subject do
        klass.new(params: {
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
      let(:schedule) do
        create(:ecf_mentor_schedule)
      end

      subject do
        klass.new(params: {
          schedule_identifier: schedule.schedule_identifier,
          participant_id: user.id,
          course_identifier: "ecf-mentor",
          cpd_lead_provider: CpdLeadProvider.new,
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
        klass.new(params: {
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
        klass.new(params: {
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
    let(:cohort) { create(:cohort) }
    let(:schedule) do
      Finance::Schedule.create!(
        cohort:,
        schedule_identifier: "soft-schedule",
        name: "soft-schedule",
      )
    end
    let!(:started_milestone) { create(:milestone, :started, :soft_milestone, schedule:) }
    let(:user) { profile.user }
    let(:profile) { create(:ecf_participant_profile) }
    let!(:declaration) do
      create(:participant_declaration,
             user:,
             participant_profile: profile,
             course_identifier: "ecf-induction")
    end

    subject do
      klass.new(params: {
        schedule_identifier: schedule.schedule_identifier,
        participant_id: user.id,
        course_identifier: "ecf-induction",
        cpd_lead_provider: CpdLeadProvider.new,
        cohort: schedule.cohort.start_year,
      })
    end

    it "changes schedule" do
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

    it "allows new provider to change schedule" do
      expect {
        subject.call
      }.to change { induction_record_2.reload.schedule }.to(new_schedule)
    end
  end
end
