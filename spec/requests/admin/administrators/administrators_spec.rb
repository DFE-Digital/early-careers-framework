# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Administrators::Administrators", type: :request do
  before do
    user = create(:user, :admin)
    sign_in user
  end

  describe "GET /admin/administrators" do
    it "renders the index template" do
      get "/admin/administrators"
      expect(response).to render_template("admin/administrators/administrators/index")
    end
  end

  describe "GET /admin/administrators/new" do
    it "renders the new tempalate" do
      get "/admin/administrators/new"
      expect(response).to render_template("admin/administrators/administrators/new")
    end
  end
end
