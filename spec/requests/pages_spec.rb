# frozen_string_literal: true

RSpec.describe "Static pages", type: :request do
  describe "GET /pages/core-materials-info" do
    it "renders the correct template" do
      get "/pages/core-materials-info"

      expect(response).to render_template("pages/core_materials_info")
    end
  end

  describe "GET /pages/year2020-core-materials-info" do
    it "renders the correct template" do
      get "/pages/year2020-core-materials-info"

      expect(response).to render_template("pages/year2020_core_materials_info")
    end
  end
end
