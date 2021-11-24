# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Gias::Schools", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:staged_school) { create(:staged_school, :closed, urn: "123456") }

  before do
    sign_in admin_user
    staged_school
  end

  describe "GET /admin/gias/schools/:id" do
    it "renders the show template" do
      get "/admin/gias/schools/#{staged_school.urn}"
      expect(response).to render_template("admin/gias/schools/show")
      expect(assigns(:school)).to eq staged_school
    end
  end
end
