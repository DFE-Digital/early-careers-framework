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
    create(:school, urn: 124_856)
  end

  describe "#run" do
    before do
      pupil_premium_importer.run
    end

    it "Adds pupil premium eligibility records to schools" do
      expect(School.first.pupil_premiums.first).to be_present
    end

    it "Sets the correct pupil premium values" do
      eligibility = School.find_by(urn: 100_006).pupil_premiums.first

      expect(eligibility.total_pupils).to be 53
      expect(eligibility.eligible_pupils).to be 43
    end

    it "handles commas in values correctly" do
      eligibility = School.find_by(urn: 124_856).pupil_premiums.first

      expect(eligibility.total_pupils).to be 1151
    end

    it "sets the correct year on the record" do
      expect(School.first.pupil_premiums.first.start_year).to be start_year
    end

    it "only creates one record per year" do
      pupil_premium_importer.run

      expect(School.first.pupil_premiums.count).to be 1
    end

    it "updates existing records" do
      old_record = School.find_by(urn: 100_006).pupil_premiums.first
      old_record.update!(eligible_pupils: 25)

      pupil_premium_importer.run

      new_record = School.find_by(urn: 100_006).pupil_premiums.first
      expect(new_record.eligible_pupils).to be 43
    end

    it "creates a new record for additional years" do
      PupilPremiumImporter.new(Logger.new($stdout), 2022, example_csv_file).run

      expect(School.first.pupil_premiums.count).to be 2
    end
  end
end
