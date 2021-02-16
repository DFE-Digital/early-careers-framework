# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolSearchForm, type: :model do
  describe "find_schools" do
    let!(:schools) do
      [create(:school, name: "Test school one", urn: "1234567"),
       create(:school, name: "Amazing school", urn: "2345678"),
       create(:school, name: "Academy", urn: "3456789")]
    end

    it "finds schools that include lowercase part of name" do
      form = SchoolSearchForm.new(school_name: "test")
      schools = form.find_schools(1)
      expect(schools.count).to eq(1)
      expect(schools.first.name).to eq("Test school one")
    end

    it "finds all schools with empty query" do
      form = SchoolSearchForm.new(school_name: "")
      schools = form.find_schools(1)
      expect(schools.count).to eq(3)
    end

    it "finds school with matching Unique Reference Number (URN)" do
      form = SchoolSearchForm.new(school_name: "2345678")
      schools = form.find_schools(1)
      expect(schools.count).to eq(1)
      expect(schools.first.name).to eql("Amazing school")
    end

    it "finds all schools with an empty query" do
      form = SchoolSearchForm.new(school_name: "")
      schools = form.find_schools(1)
      expect(schools.count).to eq(3)
    end

    it "finds schools that have a partnership" do
      school = schools[2]
      lead_provider = FactoryBot.create(:lead_provider)
      Partnership.create!(school: school, lead_provider: lead_provider)

      form = SchoolSearchForm.new(partnership: ["", "in_a_partnership"])
      search_result = form.find_schools(1)

      expect(search_result.first.name).to eql(school.name)
      expect(search_result.count).to eq(1)
    end

    it "filters schools by name and partnership status" do
      school = schools[2]
      lead_provider = FactoryBot.create(:lead_provider)
      Partnership.create!(school: school, lead_provider: lead_provider)

      form = SchoolSearchForm.new(school_name: "Test school one", partnership: ["", "in_a_partnership"])
      search_result = form.find_schools(1)

      expect(search_result.count).to eq(0)
    end
  end
end
