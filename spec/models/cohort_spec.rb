# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cohort, type: :model do
  let!(:cohort_2021) { Cohort.create!(start_year: 2021, registration_start_date: Date.new(2021, 5, 10), academic_year_start_date: Date.new(2021, 9, 1)) }
  let!(:cohort_2022) { Cohort.create!(start_year: 2022, registration_start_date: Date.new(2022, 5, 10), academic_year_start_date: Date.new(2022, 9, 1)) }

  describe "#schedules" do
    subject { described_class.create!(start_year: 3000) }

    let!(:schedule) { create(:ecf_schedule, cohort: subject) }

    it "returns associated schedules" do
      expect(subject.schedules).to include(schedule)
    end
  end

  describe ".current" do
    describe "when the current date matches the academic year start date" do
      it "returns the cohort with start_year the current year" do
        Timecop.freeze(Date.new(2021, 9, 1)) do
          expect(Cohort.current).to eq cohort_2021
        end
      end
    end

    describe "when the current date is before the registration start date of the next cohort" do
      it "returns the cohort with start_year the previous year" do
        Timecop.freeze(Date.new(2022, 4, 30)) do
          expect(Cohort.current).to eq cohort_2021
        end
      end
    end

    describe "when the current date matches the registration start date of the next cohort" do
      it "returns the cohort with start_year the previous year" do
        Timecop.freeze(Date.new(2022, 5, 1)) do
          expect(Cohort.current).to eq cohort_2021
        end
      end
    end

    describe "when the current date is before the academic year start date of the next cohort" do
      it "returns the cohort with start_year the previous year" do
        Timecop.freeze(Date.new(2022, 8, 31)) do
          expect(Cohort.current).to eq cohort_2021
        end
      end
    end
  end

  describe ".next" do
    it "returns the 2022 cohort" do
      expect(Cohort.next).to eq cohort_2022
    end
  end

  describe "description" do
    it "displays the year range" do
      expect(Cohort.new(start_year: 2022).description).to eq "2022 to 2023"
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
