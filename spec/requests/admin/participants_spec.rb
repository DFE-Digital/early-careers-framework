# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:cohort) { create(:cohort) }
  let(:school) { create(:school) }
  let!(:mentor_profile) { create :participant_profile, :mentor, school: school }
  let!(:ect_profile) { create :participant_profile, :ect, school: school, cohort: cohort, mentor_profile: mentor_profile }

  before do
    sign_in admin_user
  end

  describe "GET /admin/participants/:id" do
    it "renders the show template" do
      get "/admin/participants/#{mentor_profile.id}"
      expect(response).to render_template("admin/participants/show")
    end

    it "shows the correct participant" do
      get "/admin/participants/#{ect_profile.id}"
      expect(response.body).to include(CGI.escapeHTML(ect_profile.user.full_name))
      expect(response.body).to include(CGI.escapeHTML(mentor_profile.user.full_name))
    end
  end
end
