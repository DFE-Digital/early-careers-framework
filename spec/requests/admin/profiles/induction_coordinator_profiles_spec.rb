# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Profiles::InductionCoordinatorProfiles", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:induction_coordinator_user) { create(:user, :induction_coordinator, full_name: 'Joe Blogs', email: 'joe-blogs@example.com') }
  let(:induction_coordinator_profile){ induction_coordinator_user.induction_coordinator_profile }
  let(:induction_coordinator_user_two) { create(:user, :induction_coordinator, full_name: 'Emma Dow', email: 'emma-dow@example.com') }
  let(:induction_coordinator_profile_two){ induction_coordinator_user_two.induction_coordinator_profile }


  before do
    induction_coordinator_user
    induction_coordinator_user_two
    sign_in admin_user
  end

  describe "GET /admin/profiles/induction_coordinator_profiles" do
    it "renders the induction_coordinator_profiles template" do
      get "/admin/profiles/induction_coordinator_profiles"
      expect(response).to render_template("admin/profiles/induction_coordinator_profiles/index")
      expect(response.body).to include(CGI.escapeHTML(induction_coordinator_profile_two.user.full_name))
      expect(response.body).to include(CGI.escapeHTML(induction_coordinator_profile_two.user.email))
      expect(response.body).to include(CGI.escapeHTML(induction_coordinator_profile_two.id))
      expect(response.body).to include(CGI.escapeHTML(induction_coordinator_profile.user.full_name))
      expect(response.body).to include(CGI.escapeHTML(induction_coordinator_profile.user.email))
    end
  end

  describe "GET /admin/profiles/induction_coordinator_profile/{induction_coordinator_profile_two.id}" do
    it "renders the show template" do
      get "/admin/profiles/induction_coordinator_profiles/#{induction_coordinator_profile_two.id}"
      expect(response).to render_template("admin/profiles/induction_coordinator_profiles/show")
      expect(response.body).to include(CGI.escapeHTML(induction_coordinator_profile_two.user.full_name))
      expect(response.body).to include(CGI.escapeHTML(induction_coordinator_profile_two.user.email))
      expect(response.body).to include(CGI.escapeHTML(induction_coordinator_profile_two.id))
    end
  end

  describe "DELETE /admin/profiles/induction_coordinator_profile/{induction_coordinator_profile_two.id}" do
    it "marks the induction_coordinator profile as deleted" do
      delete "/admin/profiles/induction_coordinator_profiles/#{induction_coordinator_profile_two.id}"

      induction_coordinator_profile_two.reload
      induction_coordinator_user_two.reload
      expect(induction_coordinator_profile_two.discarded?).to be true
      expect(induction_coordinator_user_two.discarded?).to be true
    end

    it "redirects to the induction_coordinator_profile index page" do
      delete "/admin/profiles/induction_coordinator_profiles/#{induction_coordinator_profile_two.id}"

      expect(response).to redirect_to("/admin/profiles/induction_coordinator_profiles")
      expect(response.body).not_to include(CGI.escapeHTML(induction_coordinator_profile_two.user.full_name))
    end
  end
end
