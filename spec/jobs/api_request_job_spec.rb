# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiRequestJob do
  describe "#perform" do
    it "creates a ApiRequest record" do
      Sidekiq::Testing.inline! do
        expect {
          described_class.new.perform({}, {}, 401, Time.zone.now, nil)
        }.to change(ApiRequest, :count).by(1)
      end
    end

    it "detects the provider making the request from the authorization header" do
      cpd_lead_provider = create(:cpd_lead_provider, name: "Ambition")

      token = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:)

      headers = { "HTTP_AUTHORIZATION" => "Bearer #{token}" }
      described_class.new.perform({ headers: }, {}, 500, Time.zone.now, nil)

      expect(ApiRequest.find_by(cpd_lead_provider:)).not_to be_nil
      expect(ApiRequest.find_by(cpd_lead_provider:).user_description).to eq "CPD lead provider: Ambition"
    end

    it "detects the application making the request from the authorization header" do
      token = EngageAndLearnApiToken.create_with_random_token!

      headers = { "HTTP_AUTHORIZATION" => "Bearer #{token}" }
      described_class.new.perform({ headers: }, {}, 500, Time.zone.now, nil)

      expect(ApiRequest.find_by(user_description: "Engage and learn application")).not_to be_nil
    end
  end

  it "accepts headers and body in response_data" do
    described_class.new.perform(
      { path: "/api/v1/foo" },
      { headers: { "this" => "that" }, body: { "that" => "this" }.to_json },
      500,
      Time.zone.now,
      nil,
    )

    api_request = ApiRequest.find_by(request_path: "/api/v1/foo")

    expect(api_request.response_headers).to eq({ "this" => "that" })
    expect(api_request.response_body).to eq({ "that" => "this" })
  end

  it "saves the request method on the api request" do
    described_class.new.perform({ headers: {}, path: "/api/v1/bar", method: "GET" }, {}, 500, Time.zone.now, nil)

    expect(ApiRequest.find_by(request_path: "/api/v1/bar").request_method).to eq("GET")
  end

  it "saves params from GET requests" do
    described_class.new.perform({
      params: { "foo" => "meh" },
      path: "/api/v1/bar",
      method: "GET",
    }, {}, 500, Time.zone.now, nil)

    expect(ApiRequest.find_by(request_path: "/api/v1/bar").request_body).to eq("foo" => "meh")
  end

  it "saves request data from POST requests" do
    described_class.new.perform({
      body: { "foo" => "meh" }.to_json,
      path: "/api/v1/bar",
      method: "POST",
    }, {}, 500, Time.zone.now, nil)

    expect(ApiRequest.find_by(request_path: "/api/v1/bar").request_body).to eq("foo" => "meh")
  end

  it "saves request data from PUT requests" do
    described_class.new.perform({
      body: { "foo" => "meh" }.to_json,
      path: "/api/v1/bar",
      method: "PUT",
    }, {}, 500, Time.zone.now, nil)

    expect(ApiRequest.find_by(request_path: "/api/v1/bar").request_body).to eq("foo" => "meh")
  end

  it "records when POST data is not valid JSON" do
    described_class.new.perform({
      body: "This is not JSON",
      path: "/api/v1/bar",
      method: "POST",
    }, {}, 500, Time.zone.now, nil)

    expect(ApiRequest.find_by(request_path: "/api/v1/bar").request_body).to eq("error" => "request data did not contain valid JSON")
  end

  it "handles empty POST data" do
    described_class.new.perform({
      body: "",
      path: "/api/v1/bar",
      method: "POST",
    }, {}, 500, Time.zone.now, nil)

    expect(ApiRequest.find_by(request_path: "/api/v1/bar").request_body).to be_nil
  end

  context "when the api request is made by a lead provider" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, name: "Ambition") }
    let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
    let(:headers) { { "HTTP_AUTHORIZATION" => "Bearer #{token}" } }

    let(:request_uuid) { SecureRandom.uuid }

    context "when the dfe_analytics feature is enabled" do
      before { FeatureFlag.activate(:dfe_analytics) }

      let(:expected_job_data) do
        array_including(
          hash_including(
            "event_type" => "persist_api_request",
            "request_uuid" => request_uuid,
            "entity_table_name" => "api_requests",
            "user_id" => cpd_lead_provider.id,
            "data" => array_including({ "key" => "request_path", "value" => ["/api/v1/bar"] }),
          ),
        )
      end

      it "sends event to analytics with API request data and uuid" do
        expect {
          described_class.new.perform({
            headers:,
            body: { "foo" => "meh" }.to_json,
            path: "/api/v1/bar",
            method: "POST",
          }, {}, 500, Time.zone.now, request_uuid)
        }.to have_enqueued_job(DfE::Analytics::SendEvents).with(expected_job_data).on_queue("dfe_analytics")
      end
    end

    context "when the dfe_analytics feature is not enabled" do
      before { FeatureFlag.deactivate(:dfe_analytics) }

      it "does not send events to analytics" do
        expect {
          described_class.new.perform({
            headers:,
            body: { "foo" => "meh" }.to_json,
            path: "/api/v1/bar",
            method: "POST",
          }, {}, 500, Time.zone.now, request_uuid)
        }.not_to have_enqueued_job(DfE::Analytics::SendEvents)
      end
    end
  end

  context "when the api request is not made by a lead provider" do
    before { FeatureFlag.activate(:dfe_analytics) }

    it "does not send events to analytics" do
      expect {
        described_class.new.perform({
          body: { "foo" => "meh" }.to_json,
          path: "/api/v1/bar",
          method: "POST",
        }, {}, 500, Time.zone.now, anything)
      }.not_to have_enqueued_job(DfE::Analytics::SendEvents)
    end
  end
end
