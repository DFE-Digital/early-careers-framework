# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolDataImporter do
  let(:school_data_importer) { SchoolDataImporter.new(Logger.new($stdout), 2021) }
  let(:ecf_tech_csv) { File.open("spec/fixtures/files/gias_response/ecf_tech.csv") }
  let(:group_links_csv) { File.open("spec/fixtures/files/gias_response/groupLinks.csv") }
  let(:groups_csv) { File.open("spec/fixtures/files/gias_response/groups.csv") }
  let(:links_csv) { File.open("spec/fixtures/files/gias_response/links.csv") }
  let(:files) do
    {
      "ecf_tech.csv" => ecf_tech_csv,
      "groupLinks.csv" => group_links_csv,
      "groups.csv" => groups_csv,
      "links.csv" => links_csv,
    }
  end

  describe "#run" do
    context "with a successful CSV download" do
      before do
        allow_any_instance_of(GiasApiClient).to receive(:get_files).and_return(files)
      end

      it "imports each row as a school with associated Local Authority" do
        expect { school_data_importer.run }.to change { School.count }.by 3

        imported_school = School.find_by(urn: 20_001)
        expect(imported_school.name).to eql("The Starship Children's Centre")
        expect(imported_school.school_type_code).to eql(47)
        expect(imported_school.address_line1).to eql("Bar Hill Primary School")
        expect(imported_school.address_line2).to be_nil
        expect(imported_school.address_line3).to eql("Bar Hill")
        expect(imported_school.postcode).to eql("CB23 8DY")
        expect(imported_school.primary_contact_email).to eql("1@example.com")
        expect(imported_school.secondary_contact_email).to eql("2@example.com")
        expect(imported_school.administrative_district_code).to eql("E07000012")
        expect(imported_school.administrative_district_name).to eql("South Cambridgeshire")
        expect(imported_school.school_phase_type).to eql(0)
        expect(imported_school.school_phase_name).to eql("Not applicable")
        expect(imported_school.school_status_code).to eql(1)
      end

      it "correctly handles any Latin1 encoded characters in the data file" do
        school_data_importer.run

        imported_school = School.find_by(urn: 20_003)
        expect(imported_school.name).to eql("St Thomas à Becket Church of England Aided Primary School")
      end

      context "when the school already exists" do
        let!(:existing_school) { create(:school, urn: 20_001, name: "NOT The Starship Children's Centre") }

        it "updates the school record" do
          school_data_importer.run
          existing_school.reload

          expect(existing_school.name).to eql("The Starship Children's Centre")
        end
      end

      context "when the school belongs to a different local authority" do
        let!(:existing_school) do
          create(:school, urn: 20_001, name: "The Starship Children's Centre", school_local_authorities: [
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
          create(:school, urn: 20_001, name: "The Starship Children's Centre", school_local_authority_districts: [
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
