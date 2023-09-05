# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cohort, type: :model do
  let!(:cohort_2024) { FactoryBot.create :seed_cohort, start_year: 2024 }

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

    describe ".ordered_by_start_year" do
      it "orders the cohorts by year ascending" do
        expect(Cohort.ordered_by_start_year.to_sql).to include(%(ORDER BY "cohorts"."start_year" ASC))
        expect(Cohort.ordered_by_start_year.map(&:start_year)).to eql([2020, 2021, 2022, 2023, 2024])
      end
    end
  end

  describe ".current" do
    describe "when the current date matches the academic year start date" do
      it "returns the cohort with start_year the current year" do
        Timecop.freeze(Date.new(2021, 9, 1)) do
          expect(Cohort.current.start_year).to eq 2021
        end
      end
    end

    describe "when the current date is before the academic year start date of the next cohort" do
      it "returns the cohort with start_year the previous year" do
        Timecop.freeze(Date.new(2022, 8, 31)) do
          expect(Cohort.current.start_year).to eq 2021
        end
      end
    end
  end

  describe ".next" do
    describe "when the current date matches the academic year start date" do
      it "returns the cohort with start_year the next year" do
        Timecop.freeze(Date.new(2021, 9, 1)) do
          expect(Cohort.next.start_year).to eq 2022
        end
      end
    end

    describe "when the current date is before the academic year start date of the next cohort" do
      it "returns the cohort with start_year the current year" do
        Timecop.freeze(Date.new(2022, 8, 31)) do
          expect(Cohort.next.start_year).to eq 2022
        end
      end
    end
  end

  describe ".previous" do
    describe "when exactly 1 year ago matches the academic year start date" do
      it "returns the cohort with start_year the previous year" do
        Timecop.freeze(Date.new(2021, 9, 10)) do
          expect(Cohort.previous.start_year).to eq 2020
        end
      end
    end

    describe "when exactly 1 year ago is before the academic year start date of the previous cohort" do
      it "returns the cohort with start_year 2 years ago" do
        Timecop.freeze(Date.new(2022, 8, 31)) do
          expect(Cohort.previous.start_year).to eq 2020
        end
      end
    end
  end

  describe ".containing_date" do
    it "returns the cohort which contains the given date" do
      expect(Cohort.containing_date(Date.new(2021, 9, 1)).start_year).to eq 2021
      expect(Cohort.containing_date(Date.new(2022, 10, 10)).start_year).to eq 2022
      expect(Cohort.containing_date(Date.new(2023, 1, 10)).start_year).to eq 2022
      expect(Cohort.containing_date(Date.new(2024, 3, 22)).start_year).to eq 2023
    end

    context "when outside the currently added cohorts" do
      let(:oob_date) { Date.new(Cohort.maximum(:start_year) + 1, 9, 1) }

      it "returns nil" do
        expect(Cohort.containing_date(oob_date)).to be_nil
      end
    end
  end

  describe ".within_next_registration_period?" do
    before do
      Cohort.find_by(start_year: 2023).update!(registration_start_date: Date.new(2023, 6, 1), academic_year_start_date: Date.new(2023, 9, 1))
    end

    context "when the current time is after the registration start date for then next cohort" do
      it "returns true" do
        Timecop.freeze(Date.new(2023, 7, 1)) do
          expect(Cohort).to be_within_next_registration_period
        end
      end
    end

    context "when the active_registration_cohort and the current cohort are the same" do
      it "returns false" do
        Timecop.freeze(Date.new(2023, 9, 1)) do
          expect(Cohort).not_to be_within_next_registration_period
        end
      end
    end
  end

  describe "#academic_year" do
    it "displays the years covered by the academic year" do
      expect(Cohort.find_by(start_year: 2021).academic_year).to eq("2021/22")
    end
  end

  describe "#description" do
    it "displays the start and next years joined by ' to '" do
      expect(Cohort.find_by(start_year: 2022).description).to eq("2022 to 2023")
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

  describe ".active_registration_cohort" do
    describe "when the current date matches the registration start date" do
      it "returns the cohort with start_year the current year" do
        Timecop.freeze(Cohort.find_by(start_year: 2022).registration_start_date) do
          expect(Cohort.active_registration_cohort.start_year).to eq 2022
        end
      end
    end

    describe "when the current date is before the registration start date of the next cohort" do
      it "returns the cohort with start_year the previous year" do
        Timecop.freeze(Date.new(2022, 5, 11)) do
          expect(Cohort.active_npq_registration_cohort.start_year).to eq 2021
        end
      end
    end
  end

  describe ".active_npq_registration_cohort" do
    context "when npq_registration_start_date is nil" do
      it "returns Cohort.current" do
        Timecop.freeze(Date.new(2023, 3, 14)) do
          expect(Cohort.active_npq_registration_cohort.start_year).to eq 2022
        end
      end
    end

    context "when npq_registration_start_date is not nil" do
      before do
        Cohort.find_by(start_year: 2021).update!(npq_registration_start_date: Date.new(2021, 3, 14))
        Cohort.find_by(start_year: 2022).update!(npq_registration_start_date: Date.new(2022, 3, 14))
        Cohort.find_by(start_year: 2023).update!(npq_registration_start_date: Date.new(2023, 3, 14))
        Cohort.find_by(start_year: 2024).update!(npq_registration_start_date: Date.new(2024, 3, 14))
      end

      describe "when the current date matches the npq registration start date" do
        it "returns the cohort with start_year the current year" do
          Timecop.freeze(Date.new(2023, 3, 14)) do
            expect(Cohort.active_npq_registration_cohort.start_year).to eq 2023
          end
        end
      end

      describe "when the current date is before the npq registration start date of the next cohort" do
        it "returns the cohort with start_year the previous year" do
          Timecop.freeze(Date.new(2023, 3, 13)) do
            expect(Cohort.active_npq_registration_cohort.start_year).to eq 2022
          end
        end
      end
    end
  end
end
