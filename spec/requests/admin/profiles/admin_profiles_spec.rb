# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Profiles::AdminProfiles", type: :request do
  let(:admin_user) { create(:user, :admin, full_name: 'Joe Blogs', email: 'joe-blogs@example.com') }
  let(:admin_profile){ admin_user.admin_profile }
  let(:admin_user_two) { create(:user, :admin, full_name: 'Emma Dow', email: 'emma-dow@example.com') }
  let(:admin_profile_two){ admin_user_two.admin_profile }


  before do
    admin_user
    admin_user_two
    sign_in admin_user
  end

  describe "GET /admin/profiles/admin_profiles" do
    it "renders the admin_profiles template" do
      get "/admin/profiles/admin_profiles"
      expect(response).to render_template("admin/profiles/admin_profiles/index")
      expect(response.body).to include(CGI.escapeHTML(admin_profile_two.user.full_name))
      expect(response.body).to include(CGI.escapeHTML(admin_profile_two.user.email))
      expect(response.body).to include(CGI.escapeHTML(admin_profile_two.id))
      expect(response.body).to include(CGI.escapeHTML(admin_profile.user.full_name))
      expect(response.body).to include(CGI.escapeHTML(admin_profile.user.email))
    end
  end

  describe "GET /admin/profiles/admin_profile/{admin_profile_two.id}" do
    it "renders the show template" do
      get "/admin/profiles/admin_profiles/#{admin_profile_two.id}"
      expect(response).to render_template("admin/profiles/admin_profiles/show")
      expect(response.body).to include(CGI.escapeHTML(admin_profile_two.user.full_name))
      expect(response.body).to include(CGI.escapeHTML(admin_profile_two.user.email))
      expect(response.body).to include(CGI.escapeHTML(admin_profile_two.id))
    end
  end

  describe "DELETE /admin/profiles/admin_profile/{admin_profile_two.id}" do
    it "marks the admin profile as deleted" do
      delete "/admin/profiles/admin_profiles/#{admin_profile_two.id}"

      admin_profile_two.reload
      admin_user_two.reload
      expect(admin_profile_two.discarded?).to be true
      expect(admin_user_two.discarded?).to be true
    end

    it "redirects to the admin_profile index page" do
      delete "/admin/profiles/admin_profiles/#{admin_profile_two.id}"

      expect(response).to redirect_to("/admin/profiles/admin_profiles")
      expect(response.body).not_to include(CGI.escapeHTML(admin_profile_two.user.full_name))
    end
  end
end
