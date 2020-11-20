require "rails_helper"

RSpec.describe "Invite schools", type: :request do
  it "renders the school search page" do
    get "/invite_schools"
    expect(response).to render_template(:show)
  end

  it "re-renders the school search page when given invalid request" do
    get "/invite_schools"
    post "/invite_schools", params: { find_school_form: { search_type: "" } }
    expect(response).to render_template(:show)
  end

  it "redirects when given valid request" do
    get "/invite_schools"
    post "/invite_schools", params: { find_school_form: { search_type: "all" } }
    expect(response).to redirect_to(:supplier_dashboard)
  end
end
