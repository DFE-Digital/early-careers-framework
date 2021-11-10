# frozen_string_literal: true

require "rails_helper"

RSpec.describe SetSchoolLocalAuthorityDistrict do
  subject(:service) { described_class }
  let(:cohort) { create(:cohort) }
  let(:school) { create(:school, name: "Big Shiny School", urn: "123000") }
  let(:school_cohort) { create(:school_cohort, cohort: cohort, school: school) }
  let!(:participants) { create_list(:participant_profile, 2, :ecf, school_cohort: school_cohort) }
  let(:administrative_district_code) { "E12345" }
  let(:start_year) { cohort.start_year }
  let!(:local_authority_district) { create(:local_authority_district, :sparse, code: administrative_district_code) }

  describe ".call" do
    it "creates a school local authority district association record" do
      expect {
        service.call(school: school,
                     administrative_district_code: administrative_district_code,
                     start_year: start_year)
      }.to change { SchoolLocalAuthorityDistrict.count }.by(1)
    end

    it "creates an association starting from the start_year" do
      service.call(school: school,
                   administrative_district_code: administrative_district_code,
                   start_year: start_year)

      school_district = school.reload.school_local_authority_districts.latest.first
      expect(school_district.start_year).to eq start_year
      expect(school_district.end_year).to be_nil
      expect(school_district.local_authority_district).to eq local_authority_district
    end

    context "when the local authority district is already linked" do
      before do
        SchoolLocalAuthorityDistrict.create!(school: school,
                                             local_authority_district: local_authority_district,
                                             start_year: 2020)
      end

      it "does not add a new association record" do
        expect {
          service.call(school: school,
                       administrative_district_code: administrative_district_code,
                       start_year: start_year)
        }.not_to change { SchoolLocalAuthorityDistrict.count }
      end

      it "does not set the end year on the existing association" do
        service.call(school: school,
                     administrative_district_code: administrative_district_code,
                     start_year: start_year)
        expect(school.reload.school_local_authority_districts.latest.first.end_year).to be_nil
      end
    end

    context "when a school local authority record exists" do
      let(:old_la_district) { create(:local_authority_district, code: "E321") }

      before do
        SchoolLocalAuthorityDistrict.create!(school: school, local_authority_district: old_la_district, start_year: 2020)
      end

      it "sets the end year of the existing record to the start_year param" do
        old_school_la_district = school.school_local_authority_districts.latest.first
        service.call(school: school,
                     administrative_district_code: administrative_district_code,
                     start_year: start_year)
        expect(old_school_la_district.reload.end_year).to eq start_year
      end
    end

    context "when no matching local authority district exists" do
      let(:bad_la_district_code) { "E345" }

      it "raises an exception" do
        expect {
          service.call(school: school, administrative_district_code: bad_la_district_code, start_year: start_year)
        }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Local authority district must exist")
      end
    end
  end
end
