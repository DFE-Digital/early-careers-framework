# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search schools", type: :request do
  it "renders the school search page" do
    get "/school-search"
    expect(response).to render_template(:show)
  end

  it "redirects to the school search page with appropriate query params when given a post request" do
    post "/school-search", params: { search_schools_form: { school_name: "" } }
    expect(response).to redirect_to(school_search_path(school_name: ""))
  end
end
