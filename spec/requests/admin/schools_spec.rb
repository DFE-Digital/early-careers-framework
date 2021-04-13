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
  end
end
