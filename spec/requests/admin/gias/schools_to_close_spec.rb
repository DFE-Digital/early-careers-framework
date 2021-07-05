# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Gias::SchoolsToClose", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:school) { create(:school, urn: "123456") }
  let(:staged_school) { create(:staged_school, :closed, urn: "123456") }

  before do
    sign_in admin_user
    school
    staged_school
  end

  describe "GET /admin/gias/schools-to-close" do
    it "renders the index template" do
      get "/admin/gias/schools-to-close"
      expect(response).to render_template("admin/gias/schools_to_close/index")
      expect(assigns(:schools)).to match_array [staged_school]
    end
  end

  describe "GET /admin/gias/schools-to-close/:id" do
    it "renders the show template" do
      get "/admin/gias/schools-to-close/#{staged_school.urn}"
      expect(response).to render_template("admin/gias/schools_to_close/show")
      expect(assigns(:school)).to eq staged_school
    end
  end
end
