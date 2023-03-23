# frozen_string_literal: true

require "rails_helper"

class TestsController < Api::ApiController
  include ApiOrderable
end

class Test < ApplicationRecord; end

describe "ApiOrderable", type: :controller do
  before do
    allow(Test).to receive(:attribute_names).and_return(%w[id full_name])

    routes.append do
      get "index" => "tests#index"
    end
  end

  describe "sort_params" do
    controller TestsController do
      def index
        render json: { ordering_params: sort_params(params.to_unsafe_h.slice(:sort)) }
      end
    end

    it "returns formatted sort params" do
      params = { sort: "full_name" }
      get("index", params:)
      get_response = JSON.parse(response.body)

      expect(get_response["ordering_params"]).to eq({ "tests.full_name" => "asc" })
    end

    it "returns formatted sort params" do
      params = { sort: "-full_name,id" }
      get("index", params:)
      get_response = JSON.parse(response.body)

      expect(get_response["ordering_params"]).to eq({ "tests.full_name" => "desc", "tests.id" => "asc" })
    end

    it "returns formatted sort params" do
      params = { sort: "-id,full_name" }
      get("index", params:)
      get_response = JSON.parse(response.body)

      expect(get_response["ordering_params"]).to eq({ "tests.full_name" => "asc", "tests.id" => "desc" })
    end
  end
end
