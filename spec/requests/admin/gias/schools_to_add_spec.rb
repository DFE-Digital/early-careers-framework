# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Gias::SchoolsToAdd", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:staged_school) { create(:staged_school, urn: "123456") }

  before do
    sign_in admin_user
    staged_school
  end

  describe "GET /admin/gias/schools-to-add" do
    it "renders the index template" do
      get "/admin/gias/schools-to-add"
      expect(response).to render_template("admin/gias/schools_to_add/index")
      expect(assigns(:schools)).to match_array [staged_school]
    end
  end

  describe "GET /admin/gias/schools-to-add/:id" do
    it "renders the show template" do
      get "/admin/gias/schools-to-add/#{staged_school.urn}"
      expect(response).to render_template("admin/gias/schools_to_add/show")
      expect(assigns(:school)).to eq staged_school
    end
  end
end
