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

  describe "scopes" do
    describe "end dates" do
      describe ".end_date_null" do
        let!(:ir_with_null_end_date) { create(:induction_record, end_date: nil) }
        let!(:ir_with_end_date) { create(:induction_record, :with_end_date) }

        it "only includes the induction record with a null end date" do
          expect(described_class.end_date_null).to include(ir_with_null_end_date)
          expect(described_class.end_date_null).not_to include(ir_with_end_date)
        end
      end

      describe "past and future end dates" do
        let!(:ir_with_past_end_date) { create(:induction_record, end_date: 1.day.ago) }
        let!(:ir_with_future_end_date) { create(:induction_record, end_date: 1.day.from_now) }

        describe ".end_date_in_past" do
          it "only includes the induction record with an end_date in the past" do
            expect(described_class.end_date_in_past).to include(ir_with_past_end_date)
            expect(described_class.end_date_in_past).not_to include(ir_with_future_end_date)
          end
        end

        describe ".end_date_in_future" do
          it "only includes the induction record with an end_date in the future" do
            expect(described_class.end_date_in_future).to include(ir_with_future_end_date)
            expect(described_class.end_date_in_future).not_to include(ir_with_past_end_date)
          end
        end
      end
    end

    describe "start dates" do
      let!(:ir_with_past_start_date) { create(:induction_record, start_date: 1.day.ago) }
      let!(:ir_with_future_start_date) { create(:induction_record, start_date: 1.day.from_now) }

      describe ".start_date_in_past" do
        it "only includes the induction record with an start_date in the past" do
          expect(described_class.start_date_in_past).to include(ir_with_past_start_date)
          expect(described_class.start_date_in_past).not_to include(ir_with_future_start_date)
        end
      end

      describe ".start_date_in_future" do
        it "only includes the induction record with an start_date in the future" do
          expect(described_class.start_date_in_future).to include(ir_with_future_start_date)
          expect(described_class.start_date_in_future).not_to include(ir_with_past_start_date)
        end
      end
    end

    describe "school transfers" do
      let!(:ir_school_transfer) { create(:induction_record, :school_transfer) }
      let!(:ir_not_school_transfer) { create(:induction_record, :not_school_transfer) }

      describe ".school_transfer" do
        it "only includes school transfers" do
          expect(described_class.school_transfer).to include(ir_school_transfer)
          expect(described_class.school_transfer).not_to include(ir_not_school_transfer)
        end
      end

      describe ".not_school_transfer" do
        it "only includes non school transfers" do
          expect(described_class.not_school_transfer).to include(ir_not_school_transfer)
          expect(described_class.not_school_transfer).not_to include(ir_school_transfer)
        end
      end

      describe ".claimed_by_another_school" do
        # the school that the leaver is at doesn’t know they are leaving but
        # another school has told us the participant is transferring to their
        # school

        let!(:ir_school_transfer) { create(:induction_record, :school_transfer) }
        let!(:ir_leaving_school_transfer_future_end_date) { create(:induction_record, :leaving, :school_transfer) }
        let!(:ir_leaving_not_school_transfer_past_end_date) { create(:induction_record, :leaving, :not_school_transfer, :with_end_date) }
        let!(:ir_leaving_not_school_transfer_future_end_date) { create(:induction_record, :leaving, :not_school_transfer, :future_end_date) }

        it "excludes records with without status leaving" do
          expect(described_class.claimed_by_another_school).not_to include(ir_school_transfer)
        end

        it "excludes records that are leaving that are school transfers with future end date" do
          expect(described_class.claimed_by_another_school).not_to include(ir_leaving_school_transfer_future_end_date)
        end

        it "excludes records that are leaving that aren't school transfers with past end date" do
          expect(described_class.claimed_by_another_school).not_to include(ir_leaving_not_school_transfer_past_end_date)
        end

        it "includes records that are leaving that aren't school transfers with future end date" do
          expect(described_class.claimed_by_another_school).to include(ir_leaving_not_school_transfer_future_end_date)
        end
      end
    end

    describe ".active" do
      let!(:ir_with_null_end_date) { create(:induction_record, end_date: nil) }
      let!(:ir_with_future_end_date) { create(:induction_record, end_date: 1.week.from_now) }
      let!(:ir_with_future_start_date_non_transfer) { create(:induction_record, :future_start_date, :not_school_transfer) }
      let!(:ir_with_future_start_date_transfer) { create(:induction_record, :future_start_date, :school_transfer) }
      let!(:ir_with_end_date_in_past) { create(:induction_record, :past_end_date) }
      let!(:ir_with_past_start_date_transfer) { create(:induction_record, :school_transfer) }
      let!(:ir_with_past_start_date_non_transfer) { create(:induction_record, :not_school_transfer) }

      it "includes records with a past start date and a null end date" do
        expect(described_class.active).to include(ir_with_null_end_date)
      end

      it "includes records with a past start date and a future end date" do
        expect(described_class.active).to include(ir_with_future_end_date)
      end

      it "includes records with a future start date that aren't school transfers" do
        expect(described_class.active).to include(ir_with_future_start_date_non_transfer)
      end

      it "excludes records with a future start date that are school transfers" do
        expect(described_class.active).not_to include(ir_with_future_start_date_transfer)
      end

      it "excudes records with an end date in the past" do
        expect(described_class.active).not_to include(ir_with_end_date_in_past)
      end

      it "includes records with a past start date that are school transfers" do
        expect(described_class.active).to include(ir_with_past_start_date_transfer)
      end

      it "includes records with a past start date that are not school transfers" do
        expect(described_class.active).to include(ir_with_past_start_date_non_transfer)
      end
    end

    describe ".transferred" do
      let!(:ir_leaving_with_past_end_date) { create(:induction_record, :leaving, :past_end_date) }
      let!(:ir_with_past_end_date) { create(:induction_record, :past_end_date) }
      let!(:ir_leaving_with_future_end_date) { create(:induction_record, :leaving, :future_end_date) }

      it "ony includes records with leaving status and past end date" do
        expect(described_class.transferred).to include(ir_leaving_with_past_end_date)
        expect(described_class.transferred).not_to include(ir_with_past_end_date)
        expect(described_class.transferred).not_to include(ir_leaving_with_future_end_date)
      end
    end

    describe "particiant profile types" do
      let!(:ir_mentor) { create(:induction_record, :mentor) }
      let!(:ir_ect) { create(:induction_record, :ect) }

      describe ".mentors" do
        it "only includes induction records related to a ParticipantProfile::Mentor" do
          expect(described_class.mentors).to include(ir_mentor)
          expect(described_class.mentors).not_to include(ir_ect)
        end
      end

      describe ".ects" do
        it "only includes induction records related to a ParticipantProfile::ECT" do
          expect(described_class.ects).to include(ir_ect)
          expect(described_class.ects).not_to include(ir_mentor)
        end
      end
    end
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
