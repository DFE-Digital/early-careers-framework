# frozen_string_literal: true

require "rails_helper"

RSpec.describe Induction::DeleteDupRecords, versioning: true do
  let(:one_day_ago) { 1.day.ago.beginning_of_day }
  let(:two_days_ago) { 2.days.ago.beginning_of_day }
  let(:three_days_ago) { 3.days.ago.beginning_of_day }
  let(:four_days_ago) { 4.days.ago.beginning_of_day }
  let(:participant_profile) { create(:ect_participant_profile) }
  let(:first_induction_record) do
    create(:induction_record,
           :changed,
           participant_profile:,
           start_date: four_days_ago,
           end_date: three_days_ago,
           mentor_profile_id: nil,
           created_at: four_days_ago)
  end
  let(:second_induction_record) do
    create(:induction_record,
           induction_status: :completed,
           participant_profile:,
           start_date: three_days_ago,
           end_date: nil,
           mentor_profile_id: nil,
           induction_programme_id: first_induction_record.induction_programme_id,
           schedule_id: first_induction_record.schedule_id,
           created_at: three_days_ago)
  end

  let(:third_induction_record) do
    create(:induction_record,
           induction_status: :completed,
           participant_profile:,
           start_date: two_days_ago,
           end_date: nil,
           mentor_profile_id: nil,
           induction_programme_id: second_induction_record.induction_programme_id,
           schedule_id: second_induction_record.schedule_id,
           created_at: two_days_ago)
  end

  let(:last_induction_record) do
    create(:induction_record,
           induction_status: :completed,
           participant_profile:,
           start_date: one_day_ago,
           end_date: nil,
           mentor_profile_id: nil,
           induction_programme_id: third_induction_record.induction_programme_id,
           schedule_id: third_induction_record.schedule_id,
           created_at: one_day_ago)
  end

  let(:service) { described_class.new(participant_profile:) }

  before do
    first_induction_record
    second_induction_record.update!(induction_status: :changed, end_date: two_days_ago)
    third_induction_record.update!(induction_status: :changed, end_date: one_day_ago)
    last_induction_record.update!(induction_status: :changed, end_date: Date.current)
  end

  describe "#call" do
    it "never delete the first and last records", versioning: true do
      service.call

      expect(participant_profile.induction_records.reload.order(:start_date, :created_at).first).to eq(first_induction_record)
      expect(participant_profile.induction_records.reload.order(:start_date, :created_at).last).to eq(last_induction_record)
    end

    context "when a record is has no 'changed' induction_status" do
      before do
        second_induction_record.update!(induction_status: :withdrawn)
      end

      it "do not delete that record" do
        service.call

        expect(participant_profile.induction_records.reload).to include(second_induction_record)
      end
    end

    context "when a record is school_transfer" do
      before do
        second_induction_record.update!(school_transfer: true)
      end

      it "do not delete that record" do
        service.call

        expect(participant_profile.induction_records.reload).to include(second_induction_record)
      end
    end

    context "when a record is mentored" do
      before do
        second_induction_record.update!(mentor_profile_id: SecureRandom.uuid)
      end

      it "do not delete that record" do
        service.call

        expect(participant_profile.induction_records.reload).to include(second_induction_record)
      end
    end

    context "when a record was created before the bug started" do
      before do
        second_induction_record.update!(created_at: Date.new(2023, 9, 4) - 1.minute)
      end

      it "do not delete that record" do
        service.call

        expect(participant_profile.induction_records.reload).to include(second_induction_record)
      end
    end

    context "when a record was created out of the bug run window" do
      before do
        second_induction_record.update!(created_at: three_days_ago + 15.hours)
      end

      it "do not delete that record" do
        service.call

        expect(participant_profile.induction_records.reload).to include(second_induction_record)
      end
    end

    context "when a record was not created by the bug" do
      let(:version) { second_induction_record.versions.last }

      before do
        version.update!(object_changes: version.object_changes.merge("induction_status" => %w[withdrawn changed]))
      end

      it "do not delete that record" do
        service.call

        expect(participant_profile.induction_records.reload).to include(second_induction_record)
      end
    end

    context "when a record has changes other than those added by the bug" do
      before do
        second_induction_record.update!(appropriate_body_id: SecureRandom.uuid)
      end

      it "do not delete that record" do
        service.call

        expect(participant_profile.induction_records.reload).to include(second_induction_record)
      end
    end

    context "when the record is deleteable" do
      it "destroy the record and set end date of the previous one the start_date of the next one" do
        service.call

        expect(participant_profile.induction_records.reload).not_to include(second_induction_record)
        expect(first_induction_record.reload.end_date).to eq(last_induction_record.reload.start_date)
      end
    end
  end

  describe "COMPARE_ATTRIBUTES" do
    it "returns which attributes should be compared to determine a record is a dup of the previous one" do
      expect(described_class::COMPARE_ATTRIBUTES).to eq %w[induction_programme_id participant_profile_id schedule_id training_status preferred_identity_id school_transfer appropriate_body_id]
    end
  end
end
