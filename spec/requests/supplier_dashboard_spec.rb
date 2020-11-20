require "rails_helper"

RSpec.describe "Supplier dashboard", type: :request do
  it "renders the supplier dashboard page" do
    get "/supplier_dashboard"
    expect(response).to render_template(:show)
  end
end
