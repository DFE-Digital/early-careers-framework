# frozen_string_literal: true

require "rails_helper"

RSpec.describe DqtApiAccess do
  let(:expiry) { 60.minutes.from_now.to_i }
  let(:jwt_payload) { { data: "first", exp: expiry } }
  let(:jwt_token) { JWT.encode jwt_payload, nil, "none" }

  let(:response_hash) do
    {
      token_type: "Bearer",
      expires_in: 3599,
      ext_expires_in: 3599,
      access_token: jwt_token,
    }
  end

  let(:stub_token_fetch) do
    stub_request(:get, "https://dqtaccess.example.com/oauth2/v2.0/token")
      .with(
        body: {
          "client_id" => "dqt-access-guid",
          "client_secret" => "dqt-access-secret",
          "grant_type" => "client_credentials",
          "scope" => "https:///dqtaccess.example.com/some-scope",
        },
        headers: {
          "Accept" => "*/*",
          "Host" => "dqtaccess.example.com",
        },
      )
      .to_return(status: 200, body: response_hash.to_json, headers: {})
  end

  before do
    described_class.instance_variable_set :@token, nil
  end

  describe "::token" do
    it "returns a token" do
      stub_token_fetch

      expect(described_class.token).to eql(jwt_token)

      expect(stub_token_fetch).to have_been_requested.once
    end

    context "when token is ages away from expiring" do
      it "returns the existing token" do
        stub_token_fetch

        expect(described_class.token).to eql(jwt_token)
        expect(described_class.token).to eql(jwt_token)

        expect(stub_token_fetch).to have_been_requested.once
      end
    end

    context "when token is soon to expire" do
      let(:expiry) { 3.minutes.from_now.to_i }

      let(:second_expiry) { 60.minutes.from_now.to_i }
      let(:second_jwt_payload) { { data: "second", exp: second_expiry } }
      let(:second_jwt_token) { JWT.encode second_jwt_payload, nil, "none" }

      let(:second_response_hash) do
        {
          token_type: "Bearer",
          expires_in: 3599,
          ext_expires_in: 3599,
          access_token: second_jwt_token,
        }
      end

      let(:stub_second_token_fetch) do
        stub_token_fetch
          .then
          .to_return(status: 200, body: second_response_hash.to_json, headers: {})
      end

      it "returns a new token" do
        stub_second_token_fetch

        expect(described_class.token).to eql(jwt_token)
        expect(described_class.token).to eql(second_jwt_token)
      end
    end
  end
end
