# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Schedule::NPQEhco, type: :model do
  before do
    Finance::Milestone.delete_all
    Finance::Schedule.delete_all

    load Rails.root.join("db/legacy_seeds/schedules.rb").to_s
  end

  it "seeds from csv" do
    schedule = described_class.find_by(schedule_identifier: "npq-ehco-march")
    expect(schedule).to be_present
    expect(schedule.milestones.count).to eql(4)
  end

  describe ".default_for" do
    let(:cohort) { Cohort.find_by!(start_year: 2022) }
    it "returns NPQ EHCO June schedule for the cohort" do
      expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-ehco-june")

      expect(described_class.default_for(cohort:)).to eql(expected_schedule)
    end
  end

  describe ".schedule_for" do
    let(:cohort)            { Cohort.find_by!(start_year: 2022) }
    let(:cohort_start_year) { cohort.start_year }

    context "when date is between September and November of cohort start year" do
      it "returns NPQ EHCO November schedule" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-ehco-november")

        travel_to Date.new(cohort_start_year, 9, 1) do
          expect(described_class.schedule_for(cohort:)).to eq(expected_schedule)
        end
      end
    end

    context "when date is between December of cohort start year and February of the next year" do
      it "returns NPQ EHCO December schedule" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-ehco-december")

        travel_to Date.new(cohort_start_year, 12, 1) do
          expect(described_class.schedule_for(cohort:)).to eq(expected_schedule)
        end
      end
    end

    context "when date is between March and May of the next year" do
      it "returns NPQ EHCO March schedule" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-ehco-march")

        travel_to Date.new(cohort_start_year + 1, 3, 1) do
          expect(described_class.schedule_for(cohort:)).to eq(expected_schedule)
        end
      end
    end

    context "when date is between June and September of the next year" do
      it "returns NPQ EHCO June schedule" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-ehco-june")

        travel_to Date.new(cohort_start_year + 1, 6, 1) do
          expect(described_class.schedule_for(cohort:)).to eq(expected_schedule)
        end
      end
    end

    context "when date range exceeds the current cohort" do
      it "returns default schedule for cohort" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-ehco-june")

        travel_to Date.new(cohort_start_year + 1, 10, 1) do
          expect(described_class.schedule_for(cohort:)).to eq(expected_schedule)
        end
      end
    end

    context "when no schedule exists for the cohort" do
      let(:start_year) { Cohort.ordered_by_start_year.last.start_year + 128 }
      let(:cohort) { FactoryBot.create :seed_cohort, start_year: }

      it "raises an error" do
        expect { described_class.schedule_for(cohort:) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when selected cohort is before multiple schedules existed for EHCO" do
      let(:cohort) { Cohort.find_by!(start_year: 2021) }

      it "returns NPQ EHCO June schedule" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-ehco-june")

        expect(described_class.schedule_for(cohort:)).to eql(expected_schedule)
      end
    end
  end
end
