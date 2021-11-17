# frozen_string_literal: true

require "rails_helper"

RSpec.describe SetSchoolLocalAuthority do
  subject(:service) { described_class }
  let(:school) { create(:school, name: "Big Shiny School", urn: "123000") }
  let(:la_code) { "123" }
  let(:start_year) { Time.zone.now.year }
  let!(:local_authority) { create(:local_authority, code: la_code) }

  describe ".call" do
    it "creates a school local authority association record" do
      expect {
        service.call(school: school, la_code: la_code, start_year: start_year)
      }.to change { SchoolLocalAuthority.count }.by(1)
    end

    it "creates an association starting from the start_year" do
      service.call(school: school, la_code: la_code, start_year: start_year)
      school.reload
      expect(school.latest_school_authority.start_year).to eq start_year
      expect(school.latest_school_authority.end_year).to be_nil
      expect(school.latest_school_authority.local_authority).to eq local_authority
    end

    context "when the local authority is already linked" do
      before do
        SchoolLocalAuthority.create!(school: school, local_authority: local_authority, start_year: 2020)
      end

      it "does not add a new association record" do
        expect {
          service.call(school: school, la_code: la_code, start_year: start_year)
        }.not_to change { SchoolLocalAuthority.count }
      end

      it "does not set the end year on the existing association" do
        service.call(school: school, la_code: la_code, start_year: start_year)
        expect(school.reload.latest_school_authority.end_year).to be_nil
      end
    end

    context "when a school local authority record exists" do
      let(:old_local_authority) { create(:local_authority, code: "321") }

      before do
        SchoolLocalAuthority.create!(school: school, local_authority: old_local_authority, start_year: 2020)
      end

      it "sets the end year of the existing record to the start_year param" do
        old_school_local_authority = school.latest_school_authority
        service.call(school: school, la_code: la_code, start_year: start_year)
        expect(old_school_local_authority.reload.end_year).to eq start_year
      end
    end

    context "when no matching local authority exists" do
      let(:bad_la_code) { "345" }

      it "raises an exception" do
        expect {
          service.call(school: school, la_code: bad_la_code, start_year: start_year)
        }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Local authority must exist")
      end
    end
  end
end
