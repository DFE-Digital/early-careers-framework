# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Gias::SchoolsChanges", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:school) { create(:school, urn: "123456", name: "Big School") }
  let(:staged_school) { create(:staged_school, urn: "123456", name: "Medium School") }

  before do
    sign_in admin_user
    staged_school.school_changes.create!(status: :changed,
                                         attribute_changes: { "name" => [staged_school.name, school.name] })
  end

  describe "GET /admin/gias/school-changes" do
    it "renders the index template" do
      get "/admin/gias/school-changes"
      expect(response).to render_template("admin/gias/school_changes/index")
      expect(assigns(:schools)).to match_array [staged_school]
    end
  end

  describe "GET /admin/gias/school-changes/:id" do
    it "renders the show template" do
      get "/admin/gias/school-changes/#{staged_school.urn}"
      expect(response).to render_template("admin/gias/school_changes/show")
      expect(assigns(:school)).to eq staged_school
    end
  end
end
