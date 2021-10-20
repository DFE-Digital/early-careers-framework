# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiRequestJob do
  describe "#perform" do
    it "creates a ApiRequest record" do
      expect {
        described_class.new.perform({}, {}, 401, Time.zone.now)
      }.to change(ApiRequest, :count).by(1)
    end

    it "detects the provider making the request from the authorization header" do
      cpd_lead_provider = create(:cpd_lead_provider)

      token = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider)

      headers = { "HTTP_AUTHORIZATION" => "Bearer #{token}" }
      described_class.new.perform({ headers: headers }, {}, 500, Time.zone.now)

      expect(ApiRequest.find_by(cpd_lead_provider: cpd_lead_provider)).not_to be_nil
    end
  end

  it "accepts headers and body in response_data" do
    described_class.new.perform(
      { path: "/api/v1/foo" },
      { headers: { "this" => "that" }, body: { "that" => "this" }.to_json },
      500,
      Time.zone.now,
    )

    api_request = ApiRequest.find_by(request_path: "/api/v1/foo")

    expect(api_request.response_headers).to eq({ "this" => "that" })
    expect(api_request.response_body).to eq({ "that" => "this" })
  end

  it "saves the request method on the api request" do
    described_class.new.perform({ headers: {}, path: "/api/v1/bar", method: "GET" }, {}, 500, Time.zone.now)

    expect(ApiRequest.find_by(request_path: "/api/v1/bar").request_method).to eq("GET")
  end

  it "saves params from GET requests" do
    described_class.new.perform({
      params: { "foo" => "meh" },
      path: "/api/v1/bar",
      method: "GET",
    }, {}, 500, Time.zone.now)

    expect(ApiRequest.find_by(request_path: "/api/v1/bar").request_body).to eq("foo" => "meh")
  end

  it "saves request data from POST requests" do
    described_class.new.perform({
      body: { "foo" => "meh" }.to_json,
      path: "/api/v1/bar",
      method: "POST",
    }, {}, 500, Time.zone.now)

    expect(ApiRequest.find_by(request_path: "/api/v1/bar").request_body).to eq("foo" => "meh")
  end

  it "records when POST data is not valid JSON" do
    described_class.new.perform({
      body: "This is not JSON",
      path: "/api/v1/bar",
      method: "POST",
    }, {}, 500, Time.zone.now)

    expect(ApiRequest.find_by(request_path: "/api/v1/bar").request_body).to eq("error" => "request data did not contain valid JSON")
  end

  it "handles empty POST data" do
    described_class.new.perform({
      body: "",
      path: "/api/v1/bar",
      method: "POST",
    }, {}, 500, Time.zone.now)

    expect(ApiRequest.find_by(request_path: "/api/v1/bar").request_body).to be_nil
  end
end
