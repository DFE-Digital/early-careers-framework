# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateCohort do
  let(:csv) { Tempfile.new("data.csv") }
  let(:path_to_csv) { csv.path }

  subject(:importer) { described_class.new(path_to_csv:) }

  describe "#call" do
    context "with new cohorts" do
      before do
        csv.write "start-year,registration-start-date,academic-year-start-date,npq-registration-start-date"
        csv.write "\n"
        csv.write "3030,3030/05/10,3030/09/01,"
        csv.write "\n"
        csv.write "3031,3031/05/10,3031/09/01,"
        csv.write "\n"
        csv.write "3032,3032/05/10,3032/09/01,"
        csv.write "\n"
        csv.write "3033,3033/05/10,3033/09/01,"
        csv.write "\n"
        csv.close
      end

      it "creates cohort records" do
        expect { importer.call }.to change { Cohort.count }.by(4)
      end

      it "sets the correct start year on the record" do
        importer.call

        expect(Cohort.ordered_by_start_year.last.start_year).to eq 3033
      end

      it "sets the correct registration start date on the record" do
        importer.call

        cohort_3031 = Cohort.find_by(start_year: 3031)
        expect(cohort_3031.registration_start_date).to eq Date.new(3031, 5, 10)
      end

      it "only creates one cohort record per year" do
        original_cohort_count = Cohort.count
        importer.call

        expect(Cohort.select("start_year").group("start_year").pluck(:start_year).size).to be original_cohort_count + 4
      end
    end

    context "with existing cohorts" do
      let!(:cohort) do
        FactoryBot.create :seed_cohort,
                          start_year: 4041,
                          registration_start_date: Date.new(4041, 5, 1),
                          academic_year_start_date: Date.new(4041, 8, 31)
      end

      before do
        csv.write "start-year,registration-start-date,academic-year-start-date,npq-registration-start-date"
        csv.write "\n"
        csv.write "4041,4041/05/10,4041/09/01,4041/04/01"
        csv.write "\n"
        csv.close
      end

      it "updates the cohort values" do
        original_cohort_count = Cohort.count
        importer.call

        expect(Cohort.count).to eq(original_cohort_count)
        expect(cohort.reload).to have_attributes(
          registration_start_date: Date.new(4041, 5, 10),
          academic_year_start_date: Date.new(4041, 9, 1),
          npq_registration_start_date: Date.new(4041, 4, 1),
        )
      end
    end
  end
end
