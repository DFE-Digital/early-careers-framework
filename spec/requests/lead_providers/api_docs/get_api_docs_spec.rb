# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Docs - GET /lead-providers/api-docs/v1/api_spec.yml", type: :request do
  it "returns the spec in YAML format" do
    get "/lead-providers/api-docs/v1/api_spec.yml"

    expect(response).to have_http_status(200)
    expect(response.body).to match "openapi: 3.0.1"
  end
end
