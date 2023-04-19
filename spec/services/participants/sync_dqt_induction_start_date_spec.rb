# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::SyncDqtInductionStartDate, with_feature_flags: { cohortless_dashboard: "active" } do
  context "when DQT induction start date is not present" do
    let(:dqt_induction_start_date) { nil }
    let(:participant_profile) { create(:ect_participant_profile) }

    it "does not change the participant" do
      expect {
        described_class.call(dqt_induction_start_date, participant_profile)
      }.to not_change(participant_profile, :updated_at)
             .and not_change(participant_profile, :induction_start_date)
    end
  end

  context "when participant's induction start date is present" do
    let(:dqt_induction_start_date) { Date.new(2021, 9, 1) }
    let(:participant_profile) { create(:ect_participant_profile, induction_start_date: Date.new(2021, 9, 1)) }

    it "does not change the participant" do
      expect {
        described_class.call(dqt_induction_start_date, participant_profile)
      }.to not_change(participant_profile, :updated_at)
             .and not_change(participant_profile, :induction_start_date)

      expect(participant_profile.induction_start_date).to eql(Date.new(2021, 9, 1))
    end
  end

  context "when the DQT induction start date related cohort does not exist" do
    let(:dqt_induction_start_date) { Date.new(1980, 9, 1) }
    let(:participant_profile) { create(:ect_participant_profile) }
    let!(:induction_record) { create(:induction_record, participant_profile:) }

    it "does not change the participant" do
      expect {
        described_class.call(dqt_induction_start_date, participant_profile)
      }.to not_change(participant_profile, :updated_at)
             .and not_change(participant_profile, :induction_start_date)
    end
  end

  context "when the DQT induction start date's related cohort and the participant's cohort are the same" do
    let(:dqt_induction_start_date) { Date.new(2022, 10, 2) }
    let(:participant_profile) { create(:ect_participant_profile, induction_start_date: nil) }
    let!(:induction_record) { create(:induction_record, participant_profile:) }

    it "changes the participant's induction start date only" do
      expect {
        described_class.call(dqt_induction_start_date, participant_profile)
      }.to change(participant_profile, :induction_start_date).to(dqt_induction_start_date)
       .and not_change { participant_profile.induction_records.latest.cohort }
    end
  end

  context "when the DQT induction start date's related cohort and the participant's cohort are different" do
    let(:dqt_induction_start_date) { Date.new(2023, 10, 2) }
    let(:participant_profile) { create(:ect_participant_profile, induction_start_date: nil) }
    let!(:induction_record) { create(:induction_record, participant_profile:) }
    let!(:cohort) { create(:cohort, start_year: 2023) }
    let!(:school_cohort) { create(:school_cohort, :with_induction_programme, :with_ecf_standard_schedule, cohort:, school: induction_record.school) }

    it "changes the participant's induction start date and cohort" do
      expect {
        described_class.call(dqt_induction_start_date, participant_profile)
      }.to change(participant_profile, :induction_start_date).to(dqt_induction_start_date)
       .and change { participant_profile.induction_records.latest.cohort }
    end
  end
end
