# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Core Induction Programme", type: :request do
  it "renders the core_induction_programme page" do
    get "/core_induction_programme"
    expect(response).to render_template(:show)
  end
end
