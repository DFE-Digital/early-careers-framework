# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe PupilPremiumImporter do
  let(:example_csv_file) { "spec/fixtures/files/example_pupil_premium.csv" }
  let(:start_year) { 2021 }
  let(:pupil_premium_importer) { PupilPremiumImporter.new(Logger.new($stdout), start_year, example_csv_file) }

  before do
    create(:school, urn: 100_000)
    create(:school, urn: 100_006)
    create(:school, urn: 100_007)
  end

  describe "#run" do
    before do
      pupil_premium_importer.run
    end

    it "Adds pupil premium eligibility records to schools" do
      expect(School.first.pupil_premium_eligibilities.first).to be_present
    end

    it "Sets the correct pupil premium values" do
      eligibility = School.find_by(urn: 100_006).pupil_premium_eligibilities.first

      expect(eligibility.percent_primary_pupils_eligible).to be 0.0
      expect(eligibility.percent_secondary_pupils_eligible).to be 81.1
    end

    it "sets the correct year on the record" do
      expect(School.first.pupil_premium_eligibilities.first.start_year).to be start_year
    end

    it "only creates one record per year" do
      pupil_premium_importer.run

      expect(School.first.pupil_premium_eligibilities.count).to be 1
    end

    it "updates existing records" do
      old_record = School.find_by(urn: 100_006).pupil_premium_eligibilities.first
      old_record.percent_primary_pupils_eligible = 25.0
      old_record.save!

      pupil_premium_importer.run

      new_record = School.find_by(urn: 100_006).pupil_premium_eligibilities.first
      expect(new_record.percent_primary_pupils_eligible).to be 0.0
    end

    it "creates a new record for additional years" do
      PupilPremiumImporter.new(Logger.new($stdout), 2022, example_csv_file).run

      expect(School.first.pupil_premium_eligibilities.count).to be 2
    end
  end
end
