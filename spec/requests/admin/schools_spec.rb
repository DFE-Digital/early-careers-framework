# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools", type: :request do
  before do
    user = create(:user, :admin)
    sign_in user
  end

  describe "GET /admin/schools" do
    it "renders the schools template" do
      get "/admin/schools"

      expect(response).to render_template("admin/schools/index")
    end

    it "only displays eligible schools" do
      eligible_school = create(:school)
      ineligible_school = create(:school, school_status_code: 2)

      get "/admin/schools"
      expect(response.body).to include(eligible_school.urn)
      expect(response.body).not_to include(ineligible_school.urn)
    end

    it "filters the list of schools by name" do
      included_school = create(:school, name: "Include Me")
      excluded_school = create(:school, name: "Exclude Me")

      get "/admin/schools", params: { query: "include" }
      expect(response.body).to include(included_school.urn)
      expect(response.body).not_to include(excluded_school.urn)
    end

    it "filters the list of schools by urn" do
      included_school = create(:school, name: "Include Me")
      excluded_school = create(:school, name: "Exclude Me")

      get "/admin/schools", params: { query: included_school.urn }
      expect(response.body).to include(included_school.urn)
      expect(response.body).not_to include(excluded_school.urn)
    end
  end
end
