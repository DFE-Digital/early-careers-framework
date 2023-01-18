# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Schedule::NPQSpecialist, type: :model do
  before do
    load Rails.root.join("db/legacy_seeds/schedules.rb").to_s
  end

  it "seeds from csv" do
    schedule = described_class.find_by(schedule_identifier: "npq-specialist-spring")
    expect(schedule).to be_present
    expect(schedule.milestones.count).to eql(3)
  end

  describe ".default_for" do
    let(:cohort) { Cohort.find_by!(start_year: 2022) }

    it "returns NPQ Specialist Autumn 2022 schedule" do
      expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-specialist-spring")

      expect(described_class.default_for(cohort:)).to eql(expected_schedule)
    end
  end

  describe ".schedule_for" do
    let(:cohort)            { Cohort.find_by!(start_year: 2022) }
    let(:cohort_start_year) { cohort.start_year }

    context "when date is between June and December of cohort start year" do
      it "returns NPQ Specialist Autumn schedule" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-specialist-autumn")

        travel_to Date.new(cohort_start_year, 6, 1) do
          expect(described_class.schedule_for(cohort:)).to eq(expected_schedule)
        end
      end
    end

    context "when date is between December of cohort start year and April of the next year" do
      it "returns NPQ Specialist Spring schedule" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-specialist-spring")

        travel_to Date.new(cohort_start_year, 12, 26) do
          expect(described_class.schedule_for(cohort:)).to eq(expected_schedule)
        end
      end
    end

    context "when date is between April and December of the next year" do
      it "returns NPQ Specialist Autumn schedule" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-specialist-autumn")

        travel_to Date.new(cohort_start_year + 1, 4, 16) do
          expect(described_class.schedule_for(cohort:)).to eq(expected_schedule)
        end
      end
    end

    context "when date is between December of next year and April in 2 years" do
      it "returns NPQ Specialist Spring schedule" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-specialist-spring")

        travel_to Date.new(cohort_start_year + 1, 12, 26) do
          expect(described_class.schedule_for(cohort:)).to eq(expected_schedule)
        end
      end
    end

    context "when date range exceeds the current cohort" do
      it "returns default schedule for cohort" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-specialist-autumn")

        travel_to Date.new(cohort_start_year + 1, 10, 1) do
          expect(described_class.schedule_for(cohort:)).to eq(expected_schedule)
        end
      end
    end

    context "when no schedule exists for the cohort" do
      let(:cohort) { create(:cohort, start_year: 2020) }

      it "raises an error" do
        expect { described_class.schedule_for(cohort:) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when selected cohort is before multiple schedules existed for Specialist" do
      let(:cohort) { Cohort.find_by!(start_year: 2021) }

      it "returns NPQ Specialist Autumn schedule" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-specialist-autumn")

        expect(described_class.schedule_for(cohort:)).to eq(expected_schedule)
      end
    end
  end
end
