# frozen_string_literal: true

require "rails_helper"

class TestsController < Api::ApiController
  include ApiFilter
end

class Test < ApplicationRecord; end

describe "ApiFilter", type: :controller do
  before do
    routes.append do
      get "index" => "tests#index"
    end
  end

  describe "updated_since" do
    let(:now) { Time.zone.local(2023, 3, 29, 10, 10, 0) }

    controller TestsController do
      def index
        render json: { updated_since_param: updated_since }
      end
    end

    it "returns formatted datetime since the updated_since parameter" do
      params = { filter: { updated_since: now.iso8601 } }
      get("index", params:)
      get_response = JSON.parse(response.body)

      expect(get_response["updated_since_param"]).to eq("2023-03-29T10:10:00.000Z")
    end

    it "returns formatted datetime since the updated_since parameter with other formats" do
      params = { filter: { updated_since: "1980-01-01T00%3A00%3A00%2B01%3A00" } }
      get("index", params:)
      get_response = JSON.parse(response.body)

      expect(get_response["updated_since_param"]).to eq("1980-01-01T00:00:00.000+01:00")
    end

    it "returns formatted datetime since the updated_since parameter is encoded/escaped" do
      params = { filter: { updated_since: URI.encode_www_form_component(now.iso8601) } }

      Timecop.freeze(now) do
        get("index", params:)
      end

      get_response = JSON.parse(response.body)

      expect(get_response["updated_since_param"]).to eq("2023-03-29T10:10:00.000Z")
    end

    it "returns a meaningful error message" do
      params = { filter: { updated_since: "23rm21" } }
      get("index", params:)
      get_response = JSON.parse(response.body)

      expect(response).to be_bad_request
      expect(get_response).to eql(HashWithIndifferentAccess.new({
        "errors": [
          {
            "title": "Bad request",
            "detail": "The filter '#/updated_since' must be a valid RCF3339 date",
          },
        ],
      }))
    end
  end
end
