# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe PupilPremiumImporter do
  let(:example_csv_file) { "spec/fixtures/files/example_sparse_lads.csv" }
  let(:start_year) { 2021 }
  let(:sparsity_importer) { SparsityImporter.new(Logger.new($stdout), start_year, example_csv_file) }

  before do
    create(:local_authority_district, code: "E07000026")
    create(:local_authority_district, code: "E07000200")
    create(:local_authority_district, code: "E07000136")
    create(:local_authority_district, code: "E07000143")
    create(:local_authority_district, code: "E11111111")
  end

  describe "#run" do
    before do
      sparsity_importer.run
    end

    it "Creates sparsity records for districts" do
      expect(LocalAuthorityDistrict.find_by(code: "E07000026").district_sparsities.first).to be_present
    end

    it "does not create records for districts not present" do
      expect(LocalAuthorityDistrict.find_by(code: "E11111111").district_sparsities.any?).to be false
    end

    it "sets the correct year on the record" do
      expect(LocalAuthorityDistrict.find_by(code: "E07000026").district_sparsities.first.start_year).to be start_year
    end

    it "only creates one record per year" do
      sparsity_importer.run

      expect(LocalAuthorityDistrict.find_by(code: "E07000026").district_sparsities.count).to be 1
    end

    it "does not create a new record for additional years" do
      SparsityImporter.new(Logger.new($stdout), start_year + 1, example_csv_file).run

      expect(LocalAuthorityDistrict.find_by(code: "E07000026").district_sparsities.count).to be 1
    end

    it "does not update start_year for additional years" do
      SparsityImporter.new(Logger.new($stdout), start_year + 1, example_csv_file).run

      expect(LocalAuthorityDistrict.find_by(code: "E07000026").district_sparsities.first.start_year).to be start_year
    end

    it "sets the end year for districts which are no longer sparse" do
      previously_sparse_lad = LocalAuthorityDistrict.find_by(code: "E11111111")
      DistrictSparsity.create!(start_year: start_year - 1, local_authority_district: previously_sparse_lad)

      sparsity_importer.run

      expect(previously_sparse_lad.district_sparsities.count).to be 1
      expect(previously_sparse_lad.district_sparsities.first.end_year).to be start_year
    end
  end
end
