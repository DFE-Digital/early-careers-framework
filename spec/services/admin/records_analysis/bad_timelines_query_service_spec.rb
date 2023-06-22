# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::RecordsAnalysis::BadTimelinesQueryService, :with_default_schedules do
  let(:scenarios) { NewSeeds::Scenarios::Participants::TrainingRecordStates.new }

  subject { Admin::RecordsAnalysis::BadTimelinesQueryService.call(ParticipantProfile::ECF) }

  context "Given a system with a record where changes have been made after the induction start date" do
    let!(:record_with_post_start_date_changes) { scenarios.ect_on_fip_after_mentor_change.participant_profile }

    context "and changes are made to another record before the induction start date" do
      let!(:record_with_pre_start_date_changes) { scenarios.ect_on_fip_bad_timeline_before_records_start.participant_profile }

      it "includes records with invalid timelines" do
        expect(subject).to include record_with_pre_start_date_changes
      end

      it "does not include records with valid timelines" do
        expect(subject).not_to include record_with_post_start_date_changes
      end
    end

    context "and changes are made to another record after the participant has left their school" do
      let!(:record_with_pre_end_date_changes) { scenarios.ect_on_fip_withdrawn_after_leaving.participant_profile }

      it "includes records with invalid timelines" do
        expect(subject).to include record_with_pre_end_date_changes
      end

      it "does not include records with valid timelines" do
        expect(subject).not_to include record_with_post_start_date_changes
      end
    end
  end
end
