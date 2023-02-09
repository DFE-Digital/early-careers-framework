# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Users", :with_default_schedules, type: :request do
  let(:parsed_response) { JSON.parse(response.body) }
  let(:token)           { NPQRegistrationApiToken.create_with_random_token! }
  let(:bearer_token)    { "Bearer #{token}" }
  let(:authorization_header) { bearer_token }

  describe "#show" do
    let(:url) { "/api/v1/npq/users/#{user_id}.json" }

    let(:user) { create(:user, get_an_identity_id: SecureRandom.uuid) }
    let(:user_id) { user.id }

    def send_request
      get url, headers: { "Content-Type" => "application/json" }
    end

    shared_examples_for "correct response check" do
      let(:expected_response_body) { raise NotImplementedError }
      let(:expected_response_code) { raise NotImplementedError }

      it "responds correctly", :aggregate_failures do
        send_request
        expect(JSON.parse(response.body)).to eql(expected_response_body)
        expect(response).to have_http_status(expected_response_code)
      end
    end

    before do
      default_headers["Content-Type"] = "application/vnd.api+json"
      default_headers[:Authorization] = authorization_header
    end

    context "when authorized" do
      let(:authorization_header) { bearer_token }

      context "when user exists" do
        let(:user_id) { user.id }

        include_examples "correct response check" do
          let(:expected_response_code) { 200 }
          let(:expected_response_body) do
            {
              "data" => {
                "id" => user.id.to_s,
                "type" => "user",
                "attributes" => {
                  "email" => user.email,
                  "full_name" => user.full_name,
                  "get_an_identity_id" => user.get_an_identity_id,
                },
              },
            }
          end
        end
      end

      context "when user does not exist" do
        let(:user_id) { SecureRandom.uuid }

        include_examples "correct response check" do
          let(:expected_response_code) { 404 }
          let(:expected_response_body) do
            {
              "error" => "User not found",
            }
          end
        end
      end
    end

    context "when not authorized" do
      context "due to providing a non-NPQ API token" do
        let(:token) { EngageAndLearnApiToken.create_with_random_token! }

        include_examples "correct response check" do
          let(:expected_response_code) { 401 }
          let(:expected_response_body) do
            {
              "error" => "HTTP Token: Access denied",
            }
          end
        end
      end

      context "due to providing no API token" do
        let(:authorization_header) { nil }

        include_examples "correct response check" do
          let(:expected_response_code) { 401 }
          let(:expected_response_body) do
            {
              "error" => "HTTP Token: Access denied",
            }
          end
        end
      end
    end
  end
end
