# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Core Induction Programme", type: :request do
  it "renders the core_induction_programme page" do
    get "/core-induction-programme"
    expect(response).to render_template(:show)
  end

  it "redirects to cip path when user is not admin" do
    get "/core-induction-programme/download-export"
    expect(response).to redirect_to(cip_path)
  end
end
