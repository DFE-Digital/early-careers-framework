# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolSearchForm, type: :model, with_audited: true do
  describe "find_schools" do
    let!(:schools) do
      [create(:school, name: "Test school one"),
       create(:school, name: "Amazing school"),
       create(:school, name: "Academy")]
    end

    it "finds schools that include lowercase part of name" do
      form = SchoolSearchForm.new(school_name: "test")
      schools = form.find_schools
      expect(schools.count).to eq(1)
      expect(schools.first.name).to eq("Test school one")
    end

    it "finds all schools with empty query" do
      form = SchoolSearchForm.new(school_name: "")
      schools = form.find_schools
      expect(schools.count).to eq(3)
    end
  end
end
