# frozen_string_literal: true

RSpec.describe "Static pages", type: :request do
  describe "GET /pages/core-materials-info" do
    it "renders the correct template" do
      get "/pages/core-materials-info"

      expect(response).to redirect_to("https://support-for-early-career-teachers.education.gov.uk")
    end
  end

  describe "GET /pages/year-2020-core-materials-info" do
    it "renders the correct template" do
      get "/pages/year-2020-core-materials-info"

      expect(response).to render_template("pages/year_2020_core_materials_info")
    end
  end

  describe "GET /pages/what-each-person-does" do
    it "renders the correct template" do
      get "/pages/what-each-person-does"

      expect(response).to render_template("shared/_roles")
    end
  end

  describe "GET /pages/not-found", exceptions_app: true do
    it "returns 404 not found" do
      get "/pages/not-found"

      expect(response).to have_http_status(:not_found)
    end
  end
end
