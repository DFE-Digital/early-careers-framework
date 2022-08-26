# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Importers::PupilPremium do
  let(:example_csv_file) { file_fixture "example_pupil_premium_and_sparsity.csv" }
  let(:start_year) { 2021 }

  subject(:pupil_premium_importer) { described_class }

  before do
    create(:school, urn: 100_000)
    create(:school, urn: 100_006)
    create(:school, urn: 100_007)
    create(:school, urn: 124_856)
  end

  describe ".call" do
    before do
      pupil_premium_importer.call(start_year:, path_to_source_file: example_csv_file)
    end

    it "Adds pupil premium incentive records to schools" do
      expect(School.first.pupil_premiums.first).to be_present
    end

    it "Sets the correct incentives values" do
      incentives = School.find_by(urn: 100_006).pupil_premiums.first

      expect(incentives).to be_uplift
      expect(incentives).not_to be_sparse
    end

    it "sets the correct year on the record" do
      expect(School.first.pupil_premiums.first.start_year).to be start_year
    end

    it "only creates one record per year" do
      pupil_premium_importer.call(start_year:, path_to_source_file: example_csv_file)

      expect(School.first.pupil_premiums.count).to be 1
    end

    it "updates existing records" do
      old_record = School.find_by(urn: 100_006).pupil_premiums.first
      old_record.update!(sparsity_incentive: true)

      pupil_premium_importer.call(start_year:, path_to_source_file: example_csv_file)

      new_record = School.find_by(urn: 100_006).pupil_premiums.first
      expect(new_record).not_to be_sparse
    end

    it "creates a new record for additional years" do
      pupil_premium_importer.call(start_year: 2022, path_to_source_file: example_csv_file)

      expect(School.first.pupil_premiums.count).to be 2
    end

    context "when the school is not eligible" do
      before do
        School.find_by(urn: 100_000).update(school_status_code: 2)
      end

      it "updates the school" do
        expect(School.find_by(urn: 100_000).pupil_premiums.first).to be_present
      end
    end
  end
end
