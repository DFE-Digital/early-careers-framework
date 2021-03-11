# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Profiles::LeadProviderProfiles", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:lead_provider_user) { create(:user, :lead_provider, full_name: "Joe Blogs", email: "joe-blogs@example.com") }
  let(:lead_provider_profile) { lead_provider_user.lead_provider_profile }
  let(:lead_provider_user_two) { create(:user, :lead_provider, full_name: "Emma Dow", email: "emma-dow@example.com") }
  let(:lead_provider_profile_two) { lead_provider_user_two.lead_provider_profile }

  before do
    lead_provider_user
    lead_provider_user_two
    sign_in admin_user
  end

  describe "GET /admin/profiles/lead_provider_profiles" do
    it "renders the lead_provider_profiles template" do
      get "/admin/profiles/lead_provider_profiles"
      expect(response).to render_template("admin/profiles/lead_provider_profiles/index")
      expect(response.body).to include(CGI.escapeHTML(lead_provider_profile_two.user.full_name))
      expect(response.body).to include(CGI.escapeHTML(lead_provider_profile_two.user.email))
      expect(response.body).to include(CGI.escapeHTML(lead_provider_profile_two.id))
      expect(response.body).to include(CGI.escapeHTML(lead_provider_profile.user.full_name))
      expect(response.body).to include(CGI.escapeHTML(lead_provider_profile.user.email))
    end
  end

  describe "GET /admin/profiles/lead_provider_profile/{lead_provider_profile_two.id}" do
    it "renders the show template" do
      get "/admin/profiles/lead_provider_profiles/#{lead_provider_profile_two.id}"
      expect(response).to render_template("admin/profiles/lead_provider_profiles/show")
      expect(response.body).to include(CGI.escapeHTML(lead_provider_profile_two.user.full_name))
      expect(response.body).to include(CGI.escapeHTML(lead_provider_profile_two.user.email))
      expect(response.body).to include(CGI.escapeHTML(lead_provider_profile_two.id))
    end
  end

  describe "DELETE /admin/profiles/lead_provider_profile/{lead_provider_profile_two.id}" do
    it "marks the lead_provider profile as deleted" do
      delete "/admin/profiles/lead_provider_profiles/#{lead_provider_profile_two.id}"

      lead_provider_profile_two.reload
      lead_provider_user_two.reload
      expect(lead_provider_profile_two.discarded?).to be true
      expect(lead_provider_user_two.discarded?).to be true
    end

    it "redirects to the lead_provider_profile index page" do
      delete "/admin/profiles/lead_provider_profiles/#{lead_provider_profile_two.id}"

      expect(response).to redirect_to("/admin/profiles/lead_provider_profiles")
      expect(response.body).not_to include(CGI.escapeHTML(lead_provider_profile_two.user.full_name))
    end
  end
end
