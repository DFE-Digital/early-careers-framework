# frozen_string_literal: true

require "rails_helper"

RSpec.describe Induction::DeleteRecord do
  let!(:one_day_ago) { 1.day.ago.beginning_of_day }
  let!(:two_days_ago) { 2.days.ago.beginning_of_day }
  let!(:three_days_ago) { 3.days.ago.beginning_of_day }
  let(:participant_profile) { create(:ect_participant_profile) }
  let!(:induction_record) { create(:induction_record, :changed, participant_profile:, start_date: two_days_ago, end_date: one_day_ago) }
  let(:service) { described_class.new(induction_record:) }

  describe "#call" do
    context "when the record is not deletable" do
      before do
        allow(service).to receive(:middle_of_history?).and_return(false)
        allow(service).to receive(:transfer_flag_changed?).and_return(false)
        allow(service).to receive(:training_status_changed?).and_return(false)
      end

      it "raises MiddleOfHistoryError with a proper message" do
        expect { service.call }.to raise_error(Induction::DeleteRecord::MiddleOfHistoryError, "The record is not in the middle of the induction records history")
      end

      it "raises TransferFlagChangedError with a proper message" do
        allow(service).to receive(:middle_of_history?).and_return(true)
        allow(service).to receive(:transfer_flag_changed?).and_return(true)
        expect { service.call }.to raise_error(Induction::DeleteRecord::TransferFlagChangedError, "The school transfer flag has changed from the previous record")
      end

      it "raises TrainingStatusChangedError with a proper message" do
        allow(service).to receive(:middle_of_history?).and_return(true)
        allow(service).to receive(:training_status_changed?).and_return(true)
        expect { service.call }.to raise_error(Induction::DeleteRecord::TrainingStatusChangedError, "The training status has changed from the previous record")
      end
    end

    context "when the record is deletable" do
      let!(:previous_record) { create(:induction_record, :changed, participant_profile:, start_date: three_days_ago, end_date: two_days_ago) }
      let!(:next_record) { create(:induction_record, participant_profile:, start_date: one_day_ago) }

      it "updates the previous record and deletes the provided record" do
        expect { service.call }.to change { InductionRecord.count }.by(-1)
        expect(previous_record.reload.end_date).to eq(next_record.start_date)
      end

      it "does not changes the next record" do
        expect { service.call }.not_to change { next_record }
      end
    end
  end
end
