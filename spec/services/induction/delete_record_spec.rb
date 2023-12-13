# frozen_string_literal: true

require "rails_helper"

RSpec.describe Induction::DeleteRecord do
  let(:one_day_ago) { 1.day.ago.beginning_of_day }
  let(:two_days_ago) { 2.days.ago.beginning_of_day }
  let(:three_days_ago) { 3.days.ago.beginning_of_day }
  let(:participant_profile) { create(:ect_participant_profile) }
  let!(:induction_record) { create(:induction_record, :changed, participant_profile:, start_date: two_days_ago, end_date: one_day_ago) }
  let(:service) { described_class.new(induction_record:) }

  describe "#call" do
    context "when the record is not deletable" do
      before do
        allow(service).to receive(:active?).and_return(false)
        allow(service).to receive(:middle_of_history?).and_return(false)
        allow(service).to receive(:transfer_flag_changed?).and_return(false)
        allow(service).to receive(:training_status_changed?).and_return(false)
        allow(service).to receive(:mentor_changed?).and_return(false)
      end

      it "raises DeleteInductionRecordRestrictionError when not in the middle of the inductionr record history" do
        expect { service.call }.to raise_error(Induction::DeleteRecord::DeleteInductionRecordRestrictionError, "Cannot delete record because it is not in the middle of the induction records history")
      end

      it "raises DeleteInductionRecordRestrictionError when the record is active" do
        allow(service).to receive(:active?).and_return(true)
        expect { service.call }.to raise_error(Induction::DeleteRecord::DeleteInductionRecordRestrictionError, "Cannot delete record because it is active")
      end

      it "raises DeleteInductionRecordRestrictionError when the school transfer flag is not the same with the previous record" do
        allow(service).to receive(:middle_of_history?).and_return(true)
        allow(service).to receive(:transfer_flag_changed?).and_return(true)
        expect { service.call }.to raise_error(Induction::DeleteRecord::DeleteInductionRecordRestrictionError, "Cannot delete record because the school transfer flag does not matches the previous record")
      end

      it "raises DeleteInductionRecordRestrictionError when the training status is not the same with the previous record" do
        allow(service).to receive(:middle_of_history?).and_return(true)
        allow(service).to receive(:training_status_changed?).and_return(true)
        expect { service.call }.to raise_error(Induction::DeleteRecord::DeleteInductionRecordRestrictionError, "Cannot delete record because the training status does not matches the previous record")
      end

      it "raises DeleteInductionRecordRestrictionError when the mentor is not the same with the previous record" do
        allow(service).to receive(:middle_of_history?).and_return(true)
        allow(service).to receive(:mentor_changed?).and_return(true)
        expect { service.call }.to raise_error(Induction::DeleteRecord::DeleteInductionRecordRestrictionError, "Cannot delete record because the mentor does not matches the previous record")
      end
    end

    context "when the record is deletable" do
      let!(:first_induction_record) { create(:induction_record, :changed, participant_profile:, start_date: three_days_ago, end_date: two_days_ago) }
      let!(:latest_induction_record) { create(:induction_record, participant_profile:, start_date: one_day_ago) }

      it "updates the previous record and deletes the provided record" do
        expect { service.call }.to change { InductionRecord.count }.by(-1)
        expect(first_induction_record.reload.end_date).to eq(latest_induction_record.start_date)
      end

      it "does not changes the next record" do
        expect { service.call }.not_to change { latest_induction_record }
      end

      context "when two induction records have the same start date" do
        let(:start_date_of_latest_record) { one_day_ago + 1.second }
        let!(:latest_induction_record) { create(:induction_record, participant_profile:, start_date: one_day_ago, created_at: start_date_of_latest_record) }
        let!(:record_with_same_start_date) { create(:induction_record, participant_profile:, start_date: one_day_ago, end_date: start_date_of_latest_record) }

        it "updates the previous record with the start date of the correct next record" do
          service.call
          expect(first_induction_record.reload.end_date).to eq(record_with_same_start_date.start_date)
        end
      end
    end
  end
end
