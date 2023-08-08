# frozen_string_literal: true

RSpec.describe "Static pages", type: :request do
  describe "GET /pages/what-each-person-does" do
    it "renders the correct template" do
      get "/pages/what-each-person-does"

      expect(response).to render_template("shared/_roles")
    end
  end
end
