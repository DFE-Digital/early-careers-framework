# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Gias::MajorSchoolChanges", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:successor_school) { create(:school, urn: "123456") }
  let(:predecessor_school) { create(:school, urn: "100001") }
  let!(:successor_link) { create(:school_link, :successor, school: predecessor_school, link_urn: successor_school.urn) }
  let!(:predecessor_link) { create(:school_link, :predecessor, school: successor_school, link_urn: predecessor_school.urn) }

  before do
    sign_in admin_user
  end

  describe "GET /admin/gias/major-school-changes" do
    it "renders the index template" do
      get "/admin/gias/major-school-changes"
      expect(response).to render_template("admin/gias/major_school_changes/index")
      expect(assigns(:closed_schools)).to match_array [successor_link]
      expect(assigns(:opened_schools)).to match_array [predecessor_link]
    end
  end
end
