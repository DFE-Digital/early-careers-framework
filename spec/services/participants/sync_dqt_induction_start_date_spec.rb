# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::SyncDqtInductionStartDate, with_feature_flags: { cohortless_dashboard: "active" } do
  let(:dqt_induction_start_date) {}
  let(:participant_induction_start_date) {}
  let(:participant_created_at) { described_class::FIRST_2023_REGISTRATION_DATE + 1.hour }
  let(:participant_cohort_start_year) { Cohort.current.start_year }
  let(:cohort) { Cohort.find_by(start_year: participant_cohort_start_year) }
  let(:school_cohort) { create(:seed_school_cohort, :fip, :with_school, cohort:) }
  let(:induction_programme) { NewSeeds::Scenarios::InductionProgrammes::Fip.new(school_cohort:).build.induction_programme }
  let(:participant_profile) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(induction_start_date: participant_induction_start_date)
      .with_induction_record(induction_programme:)
      .participant_profile.tap { |pp| pp.update!(created_at: participant_created_at) }
  end

  subject { described_class.call(dqt_induction_start_date, participant_profile) }

  context "when 'cohortless_dashboard' feature flag is disabled" do
    before do
      FeatureFlag.deactivate(:cohortless_dashboard)
    end

    it "does not change the participant" do
      expect { subject }.to not_change(participant_profile, :updated_at)
                              .and not_change(participant_profile, :induction_start_date)
                                     .and not_change(SyncDqtInductionStartDateError, :count)
    end
  end

  context "when DQT induction start date is not present" do
    let(:dqt_induction_start_date) {}

    it "does not change the participant" do
      expect { subject }.to not_change(participant_profile, :updated_at)
                              .and not_change(participant_profile, :induction_start_date)
                                     .and not_change(SyncDqtInductionStartDateError, :count)
    end
  end

  context "when the participant is a mentor" do
    let(:dqt_induction_start_date) { Date.new(2021, 8, 31) }

    it "update only the mentor's induction start date" do
      expect { subject }.to change(participant_profile, :induction_start_date)
                              .to(dqt_induction_start_date)
                              .and not_change { participant_profile.induction_records.latest.cohort.start_year }
    end
  end

  context "when DQT induction start date is earlier than 2021/22 cohort" do
    let(:dqt_induction_start_date) { Date.new(2021, 8, 31) }

    context "when participant's induction start date is present" do
      let(:participant_induction_start_date) { Date.new(2021, 9, 1) }

      it "update the participant's induction start date" do
        expect { subject }.to change(participant_profile, :updated_at)
                                .and change(participant_profile, :induction_start_date)
                                       .and not_change(SyncDqtInductionStartDateError, :count)

        expect(participant_profile.induction_start_date).to eq(dqt_induction_start_date)
      end
    end

    context "when participant's induction start date is not present" do
      let(:participant_induction_start_date) {}

      it "update the participant's induction start date" do
        expect { subject }.to change(participant_profile, :updated_at)
                                .and change(participant_profile, :induction_start_date)
                                       .and not_change(SyncDqtInductionStartDateError, :count)

        expect(participant_profile.induction_start_date).to eq(dqt_induction_start_date)
      end
    end
  end

  context "when the participant was added to the service before 1st Jun 2023" do
    let(:participant_created_at) { Date.new(2023, 5, 31) }
    let(:dqt_induction_start_date) { Date.new(2022, 10, 1) }

    context "when participant's induction start date is present" do
      let(:participant_induction_start_date) { Date.new(2022, 9, 1) }

      it "update only the participant's induction start date" do
        expect { subject }.to change(participant_profile, :updated_at)
                                .and change(participant_profile, :induction_start_date)
                                       .and not_change(SyncDqtInductionStartDateError, :count)

        expect(participant_profile.induction_start_date).to eq(dqt_induction_start_date)
      end
    end

    context "when participant's induction start date is not present" do
      let(:participant_induction_start_date) {}

      it "update the participant's induction start date" do
        expect { subject }.to change(participant_profile, :updated_at)
                                .and change(participant_profile, :induction_start_date)
                                       .and not_change(SyncDqtInductionStartDateError, :count)

        expect(participant_profile.induction_start_date).to eq(dqt_induction_start_date)
      end
    end
  end

  context "when the participant was added to the service from registration start 2023" do
    context "when the DQT induction start date related cohort does not exist" do
      let(:dqt_induction_start_date) { Date.new(2090, 9, 1) }

      it "does not change the participant but persist the error" do
        expect { subject }.to not_change(participant_profile, :updated_at)
                                .and not_change(participant_profile, :induction_start_date)
                                       .and change(SyncDqtInductionStartDateError, :count).by(1)
      end
    end

    context "when the DQT induction start date's related cohort and the participant's cohort are the same" do
      let(:dqt_induction_start_date) { Date.new(2022, 10, 2) }
      let(:participant_cohort_start_year) { 2022 }

      it "changes the participant's induction start date only" do
        expect { subject }.to change(participant_profile, :induction_start_date)
                                .to(dqt_induction_start_date)
                                .and not_change { participant_profile.induction_records.latest.cohort }
                                       .and not_change(SyncDqtInductionStartDateError, :count)
      end
    end

    context "when the DQT induction start date's related cohort and the participant's cohort are different" do
      let(:dqt_induction_start_date) { Date.new(Cohort.current.start_year, 10, 2) }
      let(:participant_cohort_start_year) { Cohort.previous.start_year }
      let(:target_school_cohort) do
        create(:seed_school_cohort, :fip, cohort: Cohort.current, school: participant_profile.school)
      end

      before do
        NewSeeds::Scenarios::InductionProgrammes::Fip.new(school_cohort: target_school_cohort).build.induction_programme
      end

      it "changes the participant's induction start date and cohort" do
        expect { subject }.to change(participant_profile, :induction_start_date)
                                .to(dqt_induction_start_date)
                                .and change { participant_profile.induction_records.latest.cohort.start_year }
                                       .to(Cohort.current.start_year)
                                       .and not_change(SyncDqtInductionStartDateError, :count)
      end
    end

    context "when the cohort can't be amended" do
      let(:dqt_induction_start_date) { Date.new(Cohort.current.start_year, 10, 2) }
      let(:participant_cohort_start_year) { Cohort.previous.start_year }

      it "does not change the participant and save the errors" do
        expect { subject }.to not_change(participant_profile, :induction_start_date)
                                .and not_change { participant_profile.induction_records.latest.cohort.start_year }

        expect(SyncDqtInductionStartDateError.find_by(participant_profile:).message)
          .to include("Target school cohort starting on #{Cohort.current.start_year} not setup")
      end
    end

    context "when an error is already present from a previous job" do
      let(:dqt_induction_start_date) { Date.new(Cohort.current.start_year, 10, 2) }
      let!(:error) { SyncDqtInductionStartDateError.create!(participant_profile:, message: "test message") }

      context "when the participant is successfully processed" do
        let(:participant_cohort_start_year) { Cohort.current.start_year }

        it "delete the error if the participant is successfully processed" do
          expect { subject }.to change(participant_profile, :induction_start_date)
                                  .to(dqt_induction_start_date)

          expect(SyncDqtInductionStartDateError.where(participant_profile:)).not_to exist
        end
      end

      context "when the participant fails processing" do
        let(:participant_cohort_start_year) { Cohort.previous.start_year }

        it "updates the error if the process fails" do
          expect { subject }.to not_change(participant_profile, :induction_start_date)
                                  .and not_change { participant_profile.induction_records.latest.cohort.start_year }

          expect(SyncDqtInductionStartDateError.where(participant_profile:, message: "test message")).not_to exist
          expect(SyncDqtInductionStartDateError.where(participant_profile:)).to exist
        end
      end
    end
  end
end
