# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Schedule::NPQLeadership, type: :model do
  before do
    Finance::Milestone.delete_all
    Finance::Schedule.delete_all

    load Rails.root.join("db/legacy_seeds/schedules.rb").to_s
  end

  it "seeds from csv" do
    schedule = described_class.find_by(schedule_identifier: "npq-leadership-spring")
    expect(schedule).to be_present
    expect(schedule.milestones.count).to eql(4)
  end

  describe ".default_for" do
    let(:cohort) { Cohort.find_by!(start_year: 2022) }

    it "returns NPQ Leadership Spring 2022 schedule" do
      expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-leadership-spring")

      expect(described_class.default_for(cohort:)).to eql(expected_schedule)
    end
  end

  describe ".schedule_for" do
    let(:cohort)            { Cohort.find_by!(start_year: 2022) }
    let(:cohort_start_year) { cohort.start_year }

    context "when date is between June and December of cohort start year" do
      it "returns NPQ Leadership Autumn schedule" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-leadership-autumn")

        travel_to Date.new(cohort_start_year, 6, 1) do
          expect(described_class.schedule_for(cohort:)).to eq(expected_schedule)
        end
      end
    end

    context "when date is between December of cohort start year and April of the next year" do
      it "returns NPQ Leadership Spring schedule" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-leadership-spring")

        travel_to Date.new(cohort_start_year, 12, 26) do
          expect(described_class.schedule_for(cohort:)).to eq(expected_schedule)
        end
      end
    end

    context "when date is between April and December of the next year" do
      it "returns NPQ Leadership Autumn schedule" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-leadership-autumn")

        travel_to Date.new(cohort_start_year + 1, 4, 3) do
          expect(described_class.schedule_for(cohort:)).to eq(expected_schedule)
        end
      end
    end

    context "when date is between December of next year and April in 2 years" do
      it "returns NPQ Leadership Spring schedule" do
        expected_schedule = described_class.find_by(cohort:, schedule_identifier: "npq-leadership-spring")

        travel_to Date.new(cohort_start_year + 1, 12, 26) do
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
  end

  describe ".spring_schedule?" do
    it "returns true when date between Dec 26 to Apr 2" do
      (2.years.ago.year..Date.current.year).each do |year|
        (("#{year}-12-26".to_date)..("#{year + 1}-04-2".to_date)).each do |date|
          expect(described_class.spring_schedule?(date)).to be(true)
        end
      end
    end

    it "returns false when date between Apr 3 to Dec 25" do
      (2.years.ago.year..Date.current.year).each do |year|
        (("#{year}-04-3".to_date)..("#{year}-12-25".to_date)).each do |date|
          expect(described_class.spring_schedule?(date)).to be(false)
        end
      end
    end
  end

  describe ".autumn_schedule?" do
    it "returns true when date between Apr 3 to Dec 25" do
      (2.years.ago.year..Date.current.year).each do |year|
        (("#{year}-04-3".to_date)..("#{year}-12-25".to_date)).each do |date|
          expect(described_class.autumn_schedule?(date)).to be(true)
        end
      end
    end

    it "returns false when date between Dec 26 to Apr 2" do
      (2.years.ago.year..Date.current.year).each do |year|
        (("#{year}-12-26".to_date)..("#{year + 1}-04-2".to_date)).each do |date|
          expect(described_class.autumn_schedule?(date)).to be(false)
        end
      end
    end
  end
end
