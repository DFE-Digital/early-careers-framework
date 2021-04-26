# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Search schools", type: :request do
  describe "provider_events" do
    let(:parsed_response) { JSON.parse(response.body) }

    # todo: configure base path /api/v1/ with swagger helper
    it "returns 204 status" do
      post "/api/v1/provider_events"# todo: send some data... , params: { foo: "bar" }
      expect(response.status).to eq 204
    end
  end
end
