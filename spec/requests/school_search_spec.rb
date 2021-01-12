# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search schools", type: :request do
  let(:lead_provider) { FactoryBot.create(:lead_provider) }
  let(:lead_provider_user) { FactoryBot.create(:lead_provider_profile, lead_provider: lead_provider).user }

  it "renders the school search page" do
    sign_in lead_provider_user
    get "/school-search"
    expect(response).to render_template(:show)
  end

  it "redirects to the school search page with appropriate query params when given a post request" do
    sign_in lead_provider_user
    post "/school-search", params: { school_search_form: { school_name: "" } }
    expect(response).to redirect_to(school_search_path(school_name: ""))
  end

  it "redirects to log in when user is not logged in" do
    get "/school-search"
    expect(response).to redirect_to(new_user_session_path)
  end
end
