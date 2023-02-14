# frozen_string_literal: true

require "rails_helper"

RSpec.describe InductionRecord, :with_default_schedules, type: :model do
  subject(:induction_record) { create(:ect).current_induction_record }

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

    describe "current scopes" do
      let(:induction_programme) { create(:induction_programme, :fip) }
      let(:charlie_current_ir) { Induction::Enrol.call(participant_profile: create(:ecf_participant_profile), induction_programme:, start_date: 2.months.ago) }
      let(:theresa_transfer_in_ir) { Induction::Enrol.call(participant_profile: create(:ecf_participant_profile), induction_programme:, start_date: 2.months.from_now, school_transfer: true) }
      let(:linda_leaving_ir) { Induction::Enrol.call(participant_profile: create(:ecf_participant_profile), induction_programme:, start_date: 2.months.ago) }
      let(:tina_transferred_ir) { Induction::Enrol.call(participant_profile: create(:ecf_participant_profile), induction_programme:, start_date: 2.months.ago) }
      let(:wendy_withdrawn_ir) { Induction::Enrol.call(participant_profile: create(:ecf_participant_profile), induction_programme:, start_date: 2.months.ago) }
      let(:terry_transferring_out_ir) { Induction::Enrol.call(participant_profile: create(:ecf_participant_profile), induction_programme:, start_date: 2.months.ago) }

      before do
        linda_leaving_ir.leaving!(1.month.from_now)
        terry_transferring_out_ir.leaving!(1.month.from_now, transferring_out: true)
        tina_transferred_ir.leaving!(1.month.ago)
        wendy_withdrawn_ir.withdrawing!(1.day.ago)
      end

      context "when .current" do
        it "includes current users" do
          expect(induction_programme.induction_records.current_or_transferring_in).to include charlie_current_ir
        end

        it "includes transferring out users" do
          expect(induction_programme.induction_records.current_or_transferring_in).to include terry_transferring_out_ir
        end

        it "includes users leaving for another school" do
          expect(induction_programme.induction_records.current_or_transferring_in).to include linda_leaving_ir
        end

        it "does not include transferring in users" do
          expect(induction_programme.induction_records.current_or_transferring_in).to include theresa_transfer_in_ir
        end

        it "does not include transferred users" do
          expect(induction_programme.induction_records.current_or_transferring_in).not_to include tina_transferred_ir
        end

        it "does not include withdrawn users" do
          expect(induction_programme.induction_records.current_or_transferring_in).not_to include wendy_withdrawn_ir
        end
      end

      context "when .current_or_transferring_in" do
        it "includes current users" do
          expect(induction_programme.induction_records.current_or_transferring_in).to include charlie_current_ir
        end

        it "includes transferring in users" do
          expect(induction_programme.induction_records.current_or_transferring_in).to include theresa_transfer_in_ir
        end

        it "includes transferring out users" do
          expect(induction_programme.induction_records.current_or_transferring_in).to include terry_transferring_out_ir
        end

        it "includes users leaving for another school" do
          expect(induction_programme.induction_records.current_or_transferring_in).to include linda_leaving_ir
        end

        it "does not include transferred users" do
          expect(induction_programme.induction_records.current_or_transferring_in).not_to include tina_transferred_ir
        end

        it "does not include withdrawn users" do
          expect(induction_programme.induction_records.current_or_transferring_in).not_to include wendy_withdrawn_ir
        end
      end
    end

    describe "ordering" do
      describe ".oldest_first" do
        it "orders by created_at asc" do
          expect(described_class.oldest_first.to_sql).to match(%(ORDER BY CASE WHEN induction_records.end_date IS NULL THEN 1 ELSE 0 END, "induction_records"."start_date" ASC, "induction_records"."created_at" ASC))
        end
      end

      describe ".newest_first" do
        it "orders by created_at desc" do
          expect(described_class.newest_first.to_sql).to match(%(ORDER BY CASE WHEN induction_records.end_date IS NULL THEN 0 ELSE 1 END, "induction_records"."start_date" DESC, "induction_records"."created_at" DESC))
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

      context "when transferring_out" do
        it "sets the school_transfer flag to the specified value" do
          induction_record.leaving!(date_of_change, transferring_out: true)
          expect(induction_record).to be_school_transfer
        end
      end
    end
  end

  describe "callbacks" do
    it "updates analytics when an induction record is created", :with_default_schedules do
      induction_programme = create(:induction_programme)
      participant_profile = create(:ecf_participant_profile)

      expect {
        Induction::Enrol.call(participant_profile:, induction_programme:)
      }.to change { InductionRecord.count }.by(1).and have_enqueued_job(Analytics::UpsertECFInductionJob)
    end

    it "updates analytics when any attributes changes", :with_default_schedules do
      induction_record = create(:induction_record)

      expect {
        induction_record.leaving!(1.week.from_now)
      }.to have_enqueued_job(Analytics::UpsertECFInductionJob).with(
        induction_record:,
      )
    end
  end
end
