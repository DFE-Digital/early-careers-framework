# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe SchoolDataImporter do
  let(:school_data_importer) { SchoolDataImporter.new(Logger.new($stdout), 2021) }
  let(:example_csv_file) { File.open("spec/fixtures/files/example_schools_data.csv") }

  describe "#run" do
    it "downloads the file from a location based on the current date" do
      travel_to Date.new(2020, 12, 3) do
        expected_location = "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata20201203.csv"
        expected_request = stub_request(:get, expected_location).to_return(body: example_csv_file)

        school_data_importer.run

        expect(expected_request).to have_been_requested
      end
    end

    context "with a successful CSV download" do
      around do |example|
        travel_to(Date.new(2019, 1, 23)) { example.run }
      end

      let(:todays_file_url) { "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata20190123.csv" }
      let!(:request) { stub_request(:get, todays_file_url).to_return(body: example_csv_file) }

      it "imports each row as a school with associated Local Authority" do
        expect { school_data_importer.run }.to change { School.count }.by 3
        expect(request).to have_been_requested

        imported_school = School.find_by(urn: 106_653)
        expect(imported_school.name).to eql("Penistone Grammar School")
        expect(imported_school.school_type_code).to eql("01")
        expect(imported_school.capacity).to eql(1700)
        expect(imported_school.address_line1).to eql("Huddersfield Road")
        expect(imported_school.address_line2).to eql("Penistone")
        expect(imported_school.address_line3).to eql("Sheffield")
        expect(imported_school.address_line4).to eql("South Yorkshire")
        expect(imported_school.country).to eql("")
        expect(imported_school.postcode).to eql("S36 7BX")
        expect(imported_school.domains).to eql(["penistone-gs.uk"])
      end

      it "correctly handles any Latin1 encoded characters in the data file" do
        school_data_importer.run

        imported_school = School.find_by(urn: 126_416)
        expect(imported_school.name).to eql("St Thomas à Becket Church of England Aided Primary School")
      end

      context "when the school already exists" do
        let!(:existing_school) { create(:school, urn: 106_653, name: "Penistone Secondary School") }

        it "updates the school record" do
          school_data_importer.run
          existing_school.reload

          expect(existing_school.name).to eql("Penistone Grammar School")
        end
      end

      context "when the school belongs to a different local authority" do
        let!(:existing_school) do
          create(:school, urn: 106_653, name: "Penistone Secondary School", school_local_authorities: [
            build(:school_local_authority, local_authority: build(:local_authority), start_year: 2019),
          ])
        end

        it "updates the local authority" do
          school_data_importer.run
          existing_school.reload

          expect(existing_school.school_local_authorities.count).to be 2
          expect(existing_school.school_local_authorities.where(end_year: nil).count).to be 1
          expect(existing_school.school_local_authorities.where(end_year: 2021).count).to be 1
        end
      end

      context "when the school belongs to a different local authority district" do
        let!(:existing_school) do
          create(:school, urn: 106_653, name: "Penistone Secondary School", school_local_authority_districts: [
            build(:school_local_authority_district, local_authority_district: build(:local_authority_district), start_year: 2019),
          ])
        end

        it "updates the local authority district" do
          school_data_importer.run
          existing_school.reload

          expect(existing_school.school_local_authority_districts.count).to be 2
          expect(existing_school.school_local_authority_districts.where(end_year: nil).count).to be 1
          expect(existing_school.school_local_authority_districts.where(end_year: 2021).count).to be 1
        end
      end
    end
  end
end
