# frozen_string_literal: true

require "rails_helper"

class ApiFilterValidationTestsController < Api::ApiController
  include ApiFilterValidation
end

describe ApiFilterValidation, type: :controller do
  controller ApiFilterValidationTestsController do
    filter_validation required_filters: %i[cohort]

    def index
      render body: nil
    end
  end

  before do
    routes.append do
      get "index" => "api_filter_validation_tests#index"
    end
  end

  it "returns an error if the filters param is not a hash" do
    params = { filter: "wrong-format" }
    response = get("index", params:)

    expect(response.body).to match(/Bad parameter/)
    expect(response.body).to match(/Filter must be a hash/)
  end

  it "returns an error if a required filter is missing" do
    params = { filter: { foo: :bar } }
    response = get("index", params:)

    expect(response.body).to match(/The filter '#\/cohort' must be included in your request/)
  end

  it "does not return an error if a required filter is present" do
    params = { filter: { cohort: 2023 } }
    response = get("index", params:)
    expect(response.body).to be_blank
  end
end
