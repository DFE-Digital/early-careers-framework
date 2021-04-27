# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Search schools", type: :request do
  describe "provider_events" do
    let(:parsed_response) { JSON.parse(response.body) }

<<<<<<< HEAD
    # todo: configure base path /api/v1/ with swagger helper
    it "returns 201-created status" do
      post "/api/v1/provider_events"
      expect(response.status).to eq 201
    end

    xit "returns 422-unprocessable-entity status for missing params" do
      post "/api/v1/provider_events"
      expect(response.status).to eq 422
    end
=======
    # TODO: configure base path /api/v1/ with swagger helper
    it "returns 201 status" do
      post "/api/v1/provider_events" # TODO: send some data... , params: { foo: "bar" }
      expect(response.status).to eq 201
    end
>>>>>>> Move spec test to correct api/v1 directory
  end
end
