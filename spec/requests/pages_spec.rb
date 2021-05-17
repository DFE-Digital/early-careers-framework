# frozen_string_literal: true

RSpec.describe "Static pages", type: :request do
  describe "GET /pages/core-materials-info" do
    it "returns success message for current health checks" do
      get "/pages/core-materials-info"

      expect(response).to render_template("pages/core_materials_info")
    end
  end
end
