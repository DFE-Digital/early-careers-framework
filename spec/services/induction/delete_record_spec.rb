# frozen_string_literal: true

require "rails_helper"

RSpec.describe Induction::DeleteRecord do
  let!(:one_day_ago) { 1.day.ago.beginning_of_day }
  let!(:two_days_ago) { 2.days.ago.beginning_of_day }
  let!(:three_days_ago) { 3.days.ago.beginning_of_day }
  let(:participant_profile) { create(:ect_participant_profile) }
  let!(:latest_induction_record) { create(:induction_record, participant_profile:, start_date: one_day_ago) }
  let!(:mid_induction_record) { create(:induction_record, :changed, participant_profile:, start_date: two_days_ago, end_date: one_day_ago) }
  let!(:first_induction_record) { create(:induction_record, :changed, participant_profile:, start_date: three_days_ago, end_date: two_days_ago) }

  describe "#call" do
    context "when there is a next record" do
      it "deletes the an induction record in the middle and updates the end_date of the previous record" do
        service = described_class.new(induction_record: mid_induction_record)

        expect { service.call }.to change { InductionRecord.count }.by(-1)
        expect(latest_induction_record.reload.end_date).to be_nil
        expect(first_induction_record.reload.end_date).to eq(latest_induction_record.reload.start_date)
      end
    end

    context "when there is no next record" do
      it "deletes the latest induction record and updates the end_date of the previous record to nil" do
        service = described_class.new(induction_record: latest_induction_record)

        expect { service.call }.to change { InductionRecord.count }.by(-1)
        expect(mid_induction_record.reload.end_date).to be_nil
        expect(first_induction_record.reload.end_date).to eq(two_days_ago)
      end
    end

    context "when it is the first created record" do
      it "deletes the record and updates the end_date of the previous record to nil" do
        service = described_class.new(induction_record: first_induction_record)

        expect { service.call }.to change { InductionRecord.count }.by(-1)
        expect(latest_induction_record.reload.end_date).to be_nil
        expect(mid_induction_record.reload.end_date).to eq(one_day_ago)
      end
    end

    context "when the current record is the only record" do
      it "deletes the current induction record" do
        service = described_class.new(induction_record: latest_induction_record)

        expect { service.call }.to change { InductionRecord.count }.by(-1)
      end
    end
  end
end
