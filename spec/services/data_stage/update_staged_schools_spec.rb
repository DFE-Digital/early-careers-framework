# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataStage::UpdateStagedSchools do
  subject(:service) { described_class }
  let(:ecf_tech_csv) { File.open("spec/fixtures/files/gias_response/ecf_tech.csv") }
  let(:links_csv) { File.open("spec/fixtures/files/gias_response/links.csv") }
  let(:files) do
    {
      school_data_file: ecf_tech_csv.path,
      school_links_file: links_csv.path,
    }
  end

  describe ".call" do
    it "imports each school_data_file row as a DataStage::School" do
      expect { service.call(files) }.to change { DataStage::School.count }.by 3

      imported_school = DataStage::School.find_by(urn: 20_001)
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

    it "generates school change records for the new schools" do
      expect { service.call(files) }.to change { DataStage::SchoolChange.status_added.count }.by 3
    end

    it "correctly handles any Latin1 encoded characters in the data file" do
      service.call(files)

      imported_school = DataStage::School.find_by(urn: 20_003)
      expect(imported_school.name).to eql("St Thomas à Becket Church of England Aided Primary School")
    end

    context "when the school already exists" do
      let!(:existing_school) { create(:staged_school, urn: 20_001, name: "NOT The Starship Children's Centre") }

      it "updates the school record" do
        service.call(files)
        existing_school.reload

        expect(existing_school.name).to eql("The Starship Children's Centre")
      end

      it "a school change record is created" do
        expect { service.call(files) }.to change { DataStage::SchoolChange.status_changed.count }.by 1
      end
    end

    context "when the school exists and is not eligible" do
      let!(:existing_school) { create(:staged_school, urn: 20_001, name: "NOT The Starship Children's Centre", school_status_code: 2) }

      it "updates the school" do
        service.call(files)
        existing_school.reload

        expect(existing_school.name).to eql("The Starship Children's Centre")
      end
    end
  end
end
