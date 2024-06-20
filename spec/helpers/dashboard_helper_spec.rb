# frozen_string_literal: true

require "rails_helper"

RSpec.describe DashboardHelper, type: :helper do
  describe "#school_academic_years" do
    let(:cohort1) { double("Cohort", start_year: 2021, payments_frozen?: false) }
    let(:cohort2) { double("Cohort", start_year: 2022, payments_frozen?: false) }
    let(:cohort3) { double("Cohort", start_year: 2023, payments_frozen?: false) }
    let(:cohort4) { double("Cohort", start_year: 2024, payments_frozen?: true) }
    let(:cohort5) { double("Cohort", start_year: 2025, payments_frozen?: false) }

    let(:school_cohort1) { double("SchoolCohort", cohort: cohort1) }
    let(:school_cohort2) { double("SchoolCohort", cohort: cohort2) }
    let(:school_cohort3) { double("SchoolCohort", cohort: cohort3) }
    let(:school_cohort4) { double("SchoolCohort", cohort: cohort4) }
    let(:school_cohort5) { double("SchoolCohort", cohort: cohort5) }

    context "when given a collection of school cohorts" do
      it "returns up to 3 unfrozen cohorts" do
        school_cohorts = [school_cohort1, school_cohort2, school_cohort3, school_cohort4, school_cohort5]
        result = helper.school_academic_years(school_cohorts)

        expect(result).to contain_exactly(school_cohort1, school_cohort2, school_cohort3)
      end

      it "does not include frozen cohorts" do
        school_cohorts = [school_cohort1, school_cohort4, school_cohort5]
        result = helper.school_academic_years(school_cohorts)

        expect(result).to contain_exactly(school_cohort1, school_cohort5)
      end

      it "returns an empty array if all cohorts are frozen" do
        school_cohorts = [school_cohort4]
        result = helper.school_academic_years(school_cohorts)

        expect(result).to be_empty
      end
    end

    context "when given fewer than 3 unfrozen cohorts" do
      it "returns all unfrozen cohorts" do
        school_cohorts = [school_cohort1, school_cohort2]
        result = helper.school_academic_years(school_cohorts)

        expect(result).to contain_exactly(school_cohort1, school_cohort2)
      end
    end
  end
end
