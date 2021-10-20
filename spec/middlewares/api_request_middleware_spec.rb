# frozen_string_literal: true

require "rails_helper"

RSpec.describe APIRequestMiddleware, type: :request do
  let(:status) { 200 }
  let(:headers) { { HEADER: "Yeah!" } }
  let(:mock_response) { ["Hellowwworlds!"] }

  def mock_app
    main_app = lambda { |env|
      @env = env
      [status, headers, @body || mock_response]
    }

    builder = Rack::Builder.new
    builder.use APIRequestMiddleware
    builder.run main_app
    @app = builder.to_app
  end

  before do
    mock_app
    allow(ApiRequestJob).to receive(:perform)
  end

  describe "#call on a non-API path" do
    it "does not fire ApiRequestJob" do
      get "/"

      expect(ApiRequestJob).not_to have_received(:perform)
    end
  end

  describe "#call on an API path" do
    it "fires an ApiRequestJob" do
      get "/api/v1/participants/ecf", params: { foo: "bar" }

      expect(ApiRequestJob).to have_received(:perform).with(
        hash_including(path: "/api/v1/participants/ecf", params: { "foo" => "bar" }, method: "GET"), anything, 401, anything
      )
    end
  end

  describe "#call on an API path with POST data" do
    it "fires an ApiRequestJob including post data" do
      post "/api/v1/participant-declarations", as: :json, params: { foo: "bar" }

      expect(ApiRequestJob).to have_received(:perform).with(
        hash_including(path: "/api/v1/participant-declarations", body: '{"foo":"bar"}', method: "POST"), anything, 401, anything
      )
    end
  end

  describe "#call on an API path when an exception happens in the job" do
    it "logs the exception and returns" do
      allow(Rails.logger).to receive(:warn)
      allow(ApiRequestJob).to receive(:perform).and_raise(StandardError)

      get "/api/v1/participants/ecf"

      expect(Rails.logger).to have_received(:warn)
    end
  end
end
