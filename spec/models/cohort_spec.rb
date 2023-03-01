# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cohort, type: :model do
  let!(:cohort_2020) { Cohort.find_by(start_year: 2020) || create(:cohort, start_year: 2020) }
  let!(:cohort_2021) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }
  let!(:cohort_2022) { Cohort.find_by(start_year: 2022) || create(:cohort, start_year: 2022) }
  let!(:cohort_2023) { Cohort.find_by(start_year: 2023) || create(:cohort, start_year: 2023) }
  let!(:cohort_2024) { Cohort.find_by(start_year: 2024) || create(:cohort, start_year: 2024) }

  describe "scopes" do
    describe ".between_years" do
      it "generates a BETWEEN clause with the given years" do
        expected = %(WHERE "cohorts"."start_year" BETWEEN 1 AND 5)
        expect(Cohort.between_years(1, 5).to_sql).to include(expected)
      end
    end

    describe ".between_2021_and" do
      it "generates a BETWEEN clause with 2021 and the given year" do
        expected = %(WHERE "cohorts"."start_year" BETWEEN 2021 AND 2030)
        expect(Cohort.between_2021_and(2030).to_sql).to include(expected)
      end
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

    describe "when the current date is before the academic year start date of the next cohort" do
      it "returns the cohort with start_year the previous year" do
        Timecop.freeze(Date.new(2022, 8, 31)) do
          expect(Cohort.current).to eq cohort_2021
        end
      end
    end
  end

  describe ".next" do
    describe "when the current date matches the academic year start date" do
      it "returns the cohort with start_year the next year" do
        Timecop.freeze(Date.new(2021, 9, 1)) do
          expect(Cohort.next).to eq cohort_2022
        end
      end
    end

    describe "when the current date is before the academic year start date of the next cohort" do
      it "returns the cohort with start_year the current year" do
        Timecop.freeze(Date.new(2022, 8, 31)) do
          expect(Cohort.next).to eq cohort_2022
        end
      end
    end
  end

  describe ".previous" do
    describe "when exactly 1 year ago matches the academic year start date" do
      it "returns the cohort with start_year the previous year" do
        Timecop.freeze(Date.new(2021, 9, 1)) do
          expect(Cohort.previous).to eq cohort_2020
        end
      end
    end

    describe "when exactly 1 year ago is before the academic year start date of the previous cohort" do
      it "returns the cohort with start_year 2 years ago" do
        Timecop.freeze(Date.new(2022, 8, 31)) do
          expect(Cohort.previous).to eq cohort_2020
        end
      end
    end
  end

  describe "#academic_year" do
    it "displays the years covered by the academic year" do
      expect(cohort_2021.academic_year).to eq("2021/22")
    end
  end

  describe "#description" do
    it "displays the start and next years joined by ' to '" do
      expect(cohort_2022.description).to eq("2022 to 2023")
    end
  end

  describe "#display_name" do
    it "returns the start year as a string" do
      expect(cohort_2024.display_name).to eq("2024")
    end
  end

  describe "#schedules" do
    subject { described_class.create!(start_year: 3000) }

    let!(:schedule) { create(:ecf_schedule, cohort: subject) }

    it "returns associated schedules" do
      expect(subject.schedules).to include(schedule)
    end
  end
end
