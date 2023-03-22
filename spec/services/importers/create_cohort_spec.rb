# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateCohort do
  let(:csv) { Tempfile.new("data.csv") }
  let(:path_to_csv) { csv.path }

  subject(:importer) { described_class.new(path_to_csv:) }

  describe "#call" do
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
end
