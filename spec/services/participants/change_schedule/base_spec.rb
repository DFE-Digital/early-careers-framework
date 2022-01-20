# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::ChangeSchedule::Base do
  let(:klass) do
    Class.new(described_class) do
      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      def self.valid_courses
        %w[some-course]
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
          course_identifier: "some-course",
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
  end

  describe "changing to a soft schedules with previous declarations" do
    let(:cohort) { create(:cohort) }
    let(:schedule) do
      Finance::Schedule.create!(
        cohort: cohort,
        schedule_identifier: "soft-schedule",
        name: "soft-schedule",
      )
    end
    let!(:started_milestone) { create(:milestone, :started, :soft_milestone, schedule: schedule) }
    let(:user) { profile.user }
    let(:profile) { create(:ecf_participant_profile) }
    let!(:declaration) do
      create(:participant_declaration,
             user: user,
             participant_profile: profile,
             course_identifier: "ecf-induction")
    end

    subject do
      klass.new(params: {
        schedule_identifier: schedule.schedule_identifier,
        participant_id: user.id,
        course_identifier: "some-course",
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
end
