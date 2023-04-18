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
        csv.write "2020,2020/05/10,2020/09/01,"
        csv.write "\n"
        csv.write "2021,2021/05/10,2021/09/01,"
        csv.write "\n"
        csv.write "2022,2022/05/10,2022/09/01,"
        csv.write "\n"
        csv.write "2023,2023/05/10,2023/09/01,"
        csv.write "\n"
        csv.close
      end

      it "creates cohort records" do
        expect {
          importer.call
        }.to change(Cohort, :count).by(4)
      end

      it "sets the correct start year on the record" do
        importer.call

        expect(Cohort.order(:start_year).last.start_year).to eq(2023)
      end

      it "sets the correct registration start date on the record" do
        importer.call

        cohort = Cohort.find_by(start_year: 2022)

        expect(cohort.registration_start_date).to eq(Date.parse("10/05/2022"))
      end

      it "only creates one cohort record per year" do
        importer.call

        expect(Cohort.select("start_year").group("start_year").pluck(:start_year).size).to be 4
      end
    end

    context "with existing cohorts" do
      let!(:cohort_2023) { create(:cohort, start_year: 2023, registration_start_date: Date.new(2023, 5, 1), academic_year_start_date: Date.new(2023, 8, 31)) }

      before do
        csv.write "start-year,registration-start-date,academic-year-start-date,npq-registration-start-date"
        csv.write "\n"
        csv.write "2023,2023/05/10,2023/09/01,2023/04/01"
        csv.write "\n"
        csv.close
      end

      it "updates the cohort values" do
        importer.call

        expect(Cohort.count).to eq(1)
        expect(cohort_2023.reload).to have_attributes(
          registration_start_date: Date.new(2023, 5, 10),
          academic_year_start_date: Date.new(2023, 9, 1),
          npq_registration_start_date: Date.new(2023, 4, 1),
        )
      end
    end
  end
end
