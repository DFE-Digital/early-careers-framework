# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Docs - GET /lead-providers/api-docs/:api_version/api_spec.yml", type: :request do
  it "returns the spec in YAML format for existing version" do
    get "/lead-providers/api-docs/v1/api_spec.yml"

    expect(response).to have_http_status(200)
    expect(response.body).to match "openapi: 3.0.1"
  end

  it "returns the spec in YAML format for current version" do
    get "/lead-providers/api-docs/v3/api_spec.yml"

    expect(response).to have_http_status(200)
    expect(response.body).to match "openapi: 3.0.1"
  end

  it "returns a 404 for non existing version", exceptions_app: true do
    get "/lead-providers/api-docs/v1.2/api_spec.yml"

    expect(response).to have_http_status(404)
  end
end
