# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateCohort do
  let(:csv) { Tempfile.new("data.csv") }
  let(:path_to_csv) { csv.path }

  let(:start_year) { Cohort.ordered_by_start_year.last.start_year + 50 }

  subject(:importer) { described_class.new(path_to_csv:) }

  describe "#call" do
    context "with new cohorts" do
      before do
        csv.write "start-year,registration-start-date,academic-year-start-date,npq-registration-start-date"
        csv.write "\n"
        4.times.each do |n|
          year = start_year + n
          csv.write "#{year},#{year}/05/10,#{year}/09/01,"
          csv.write "\n"
        end
        csv.close
      end

      it "creates cohort records" do
        expect {
          importer.call
        }.to change(Cohort, :count).by(4)
      end

      it "sets the correct start year on the record" do
        importer.call

        expect(Cohort.ordered_by_start_year.last.start_year).to eq(start_year + 3)
      end

      it "sets the correct registration start date on the record" do
        importer.call

        cohort = Cohort.find_by(start_year: start_year + 1)

        expect(cohort.registration_start_date).to eq(Date.parse("10/05/#{start_year + 1}"))
      end

      it "only creates one cohort record per year" do
        original_cohort_count = Cohort.count
        importer.call

        expect(Cohort.select("start_year").group("start_year").pluck(:start_year).size).to be original_cohort_count + 4
      end
    end

    context "with existing cohorts" do
      let!(:cohort) { FactoryBot.create(:seed_cohort, start_year:, registration_start_date: Date.new(start_year, 5, 1), academic_year_start_date: Date.new(start_year, 8, 31)) }

      before do
        csv.write "start-year,registration-start-date,academic-year-start-date,npq-registration-start-date"
        csv.write "\n"
        csv.write "#{start_year},#{start_year}/05/10,#{start_year}/09/01,#{start_year}/04/01"
        csv.write "\n"
        csv.close
      end

      it "updates the cohort values" do
        original_cohort_count = Cohort.count
        importer.call

        expect(Cohort.count).to eq(original_cohort_count)
        expect(cohort.reload).to have_attributes(
          registration_start_date: Date.new(start_year, 5, 10),
          academic_year_start_date: Date.new(start_year, 9, 1),
          npq_registration_start_date: Date.new(start_year, 4, 1),
        )
      end
    end
  end
end
