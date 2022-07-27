# frozen_string_literal: true

require "rails_helper"

RSpec.describe InductionRecord, type: :model do
  subject(:induction_record) { create(:induction_record) }

  describe "changes" do
    before do
      induction_record.participant_profile.update!(created_at: 2.weeks.ago, updated_at: 1.week.ago)
    end

    it "updates the updated_at on the participant_profile" do
      induction_record.touch
      expect(induction_record.participant_profile.updated_at).to be_within(1.second).of induction_record.updated_at
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:induction_programme) }
    it { is_expected.to belong_to(:participant_profile) }
    it { is_expected.to belong_to(:schedule) }
    it { is_expected.to belong_to(:preferred_identity).optional }
    it { is_expected.to belong_to(:mentor_profile).optional }
    it { is_expected.to have_one(:partnership).through(:induction_programme) }
    it { is_expected.to have_one(:lead_provider).through(:partnership) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:start_date) }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:induction_status).with_values(
        active: "active",
        withdrawn: "withdrawn",
        changed: "changed",
        leaving: "leaving",
        completed: "completed",
      ).with_suffix.backed_by_column_of_type(:string)
    }

    it {
      is_expected.to define_enum_for(:training_status).with_values(
        active: "active",
        deferred: "deferred",
        withdrawn: "withdrawn",
      ).with_prefix("training_status").backed_by_column_of_type(:string)
    }
  end

  describe "#changing!" do
    it "sets the induction_status to changed" do
      induction_record.changing!
      expect(induction_record).to be_changed_induction_status
    end

    it "sets the end_date to the current date and time" do
      induction_record.changing!
      expect(induction_record.end_date).to be_within(1.second).of(Time.zone.now)
    end

    context "when a date of change is supplied" do
      let(:date_of_change) { 1.week.from_now }

      it "sets the end_date to the specified date of change" do
        induction_record.changing!(date_of_change)
        expect(induction_record.end_date).to be_within(1.second).of(date_of_change)
      end
    end
  end

  describe "#withdrawing!" do
    it "sets the induction_status to withdrawn" do
      induction_record.withdrawing!
      expect(induction_record).to be_withdrawn_induction_status
    end

    it "sets the end_date to the current date and time" do
      induction_record.withdrawing!
      expect(induction_record.end_date).to be_within(1.second).of(Time.zone.now)
    end

    context "when a date of change is supplied" do
      let(:date_of_change) { 1.week.from_now }

      it "sets the end_date to the specified date of change" do
        induction_record.withdrawing!(date_of_change)
        expect(induction_record.end_date).to be_within(1.second).of(date_of_change)
      end
    end
  end

  describe "#leaving!" do
    it "sets the induction_status to leaving" do
      induction_record.leaving!
      expect(induction_record).to be_leaving_induction_status
    end

    it "sets the end_date to the current date and time" do
      induction_record.leaving!
      expect(induction_record.end_date).to be_within(1.second).of(Time.zone.now)
    end

    context "when a date of change is supplied" do
      let(:date_of_change) { 1.week.from_now }

      it "sets the end_date to the specified date of change" do
        induction_record.leaving!(date_of_change)
        expect(induction_record.end_date).to be_within(1.second).of(date_of_change)
      end
    end
  end

  describe "withdrawal" do
    let(:participant_profile) { create :ect_participant_profile }
    let(:lead_provider) { create(:lead_provider) }
    let(:partnership) { create(:partnership, lead_provider:) }
    let(:induction_programme) { create(:induction_programme, partnership:) }
    let(:induction_record) { create(:induction_record, induction_programme:, participant_profile:) }

    let(:update_training_status_to_active) do
      induction_record.update!(training_status: "active")
    end

    let(:update_training_status_to_deferred) do
      induction_record.update!(training_status: "deferred")
    end

    before do
      induction_record.update!(training_status: "withdrawn")
    end

    it "returns an error if the training_status change is from withdrawn to active" do
      expect { update_training_status_to_active }
        .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Cannot resume a withdrawn participant")
    end

    it "returns an error if the training_status change is from withdrawn to deferred" do
      expect { update_training_status_to_deferred }
        .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Cannot resume a withdrawn participant")
    end
  end
end
