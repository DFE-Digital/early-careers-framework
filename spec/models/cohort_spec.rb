# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cohort, type: :model do
  let!(:cohort_2021) { Cohort.create!(start_year: 2021) }
  let!(:cohort_2022) { Cohort.create!(start_year: 2022) }

  describe "#schedules" do
    subject { described_class.create!(start_year: 3000) }

    let!(:schedule) { create(:ecf_schedule, cohort: subject) }

    it "returns associated schedules" do
      expect(subject.schedules).to include(schedule)
    end
  end

  describe ".current" do
    it "returns the 2021 cohort" do
      expect(Cohort.current).to eq cohort_2021
    end
  end

  describe ".next" do
    context "when the feature flag is deactivated" do
      it "returns the 2021 cohort" do
        FeatureFlag.deactivate(:multiple_cohorts)

        expect(Cohort.next).to eq cohort_2021
      end
    end

    context "when the feature flag is activated" do
      it "returns the 2022 cohort" do
        FeatureFlag.activate(:multiple_cohorts)

        expect(Cohort.next).to eq cohort_2022
      end
    end
  end

  describe "display_name" do
    it "displays the correct year" do
      expect(Cohort.new(start_year: 2021).display_name).to eq "2021"
    end
  end

  describe "academic_year" do
    it "displays the years covered by the academic year" do
      expect(Cohort.new(start_year: 2021).academic_year).to eq "2021/22"
    end
  end
end
