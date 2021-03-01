# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LeadProvider::SearchSchools", type: :request do
  before do
    user = create(:user, :lead_provider)
    sign_in user
  end

  describe "#show" do
    it "render the show template" do
      get "/lead-provider/search-schools"

      expect(response).to render_template(:show)
    end
  end

  describe "#create" do
    it "redirects to the school search page with appropriate query params when given a post request" do
      post "/lead-provider/search-schools", params: { school_search_form: { school_name: "" } }
      expect(response).to redirect_to(lead_provider_search_schools_path(school_name: ""))
    end
  end
end
