# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiRequestMiddleware do
  let(:status) { 200 }
  let(:headers) { { "HEADER" => "Yeah!" } }
  let(:mock_response) { ["Hellowwworlds!"] }

  let(:mock_app) do
    lambda do |env|
      @env = env
      [status, headers, @body || mock_response]
    end
  end

  subject { described_class.new(mock_app) }

  let(:request) { Rack::MockRequest.new(subject) }

  before do
    allow(ApiRequestJob).to receive(:perform_async)
  end

  describe "#call on a non-API path" do
    it "does not fire ApiRequestJob" do
      request.get "/"

      expect(ApiRequestJob).not_to have_received(:perform_async)
    end
  end

  describe "#call on an API path" do
    it "fires an ApiRequestJob" do
      request.get "/api/v1/participants/ecf", params: { foo: "bar" }

      expect(ApiRequestJob).to have_received(:perform_async).with(
        hash_including("path" => "/api/v1/participants/ecf", "params" => { "foo" => "bar" }, "method" => "GET"), anything, 200, anything
      )
    end
  end

  describe "#call on a different version API path" do
    it "fires an ApiRequestJob" do
      request.get "/api/v3/participants/ecf", params: { foo: "bar" }

      expect(ApiRequestJob).to have_received(:perform_async).with(
        hash_including("path" => "/api/v3/participants/ecf", "params" => { "foo" => "bar" }, "method" => "GET"), anything, 200, anything
      )
    end
  end

  describe "#call on an API path with POST data" do
    it "fires an ApiRequestJob including post data" do
      request.post "/api/v1/participant-declarations", as: :json, params: { foo: "bar" }.to_json

      expect(ApiRequestJob).to have_received(:perform_async).with(
        hash_including("path" => "/api/v1/participant-declarations", "body" => '{"foo":"bar"}', "method" => "POST"), anything, 200, anything
      )
    end
  end

  describe "#call on an API path when an exception happens in the job" do
    it "logs the exception and returns" do
      allow(Rails.logger).to receive(:warn)
      allow(ApiRequestJob).to receive(:perform_async).and_raise(StandardError)

      request.get "/api/v1/participants/ecf"

      expect(Rails.logger).to have_received(:warn)
    end
  end
end
