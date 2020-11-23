require "rails_helper"

RSpec.describe "Invite schools", type: :request do
  it "renders the school search page" do
    get "/school_invites"
    expect(response).to render_template(:show)
  end

  it "re-renders the school search page when given invalid request" do
    post "/school_invites", params: { find_school_form: { search_type: "" } }
    expect(response).to render_template(:show)
  end

  it "redirects when given valid request" do
    post "/school_invites", params: { find_school_form: { search_type: "all" } }
    expect(response).to redirect_to(:supplier_dashboard)
  end
end
