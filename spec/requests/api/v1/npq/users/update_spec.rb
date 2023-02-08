# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Users", :with_default_schedules, type: :request do
  let(:parsed_response) { JSON.parse(response.body) }
  let(:token)           { NPQRegistrationApiToken.create_with_random_token! }
  let(:bearer_token)    { "Bearer #{token}" }
  let(:authorization_header) { bearer_token }

  describe "#update" do
    let(:url) { "/api/v1/npq/users/#{user_id}.json" }

    let(:user) { create(:user) }
    let(:user_id) { user.id }
    let(:get_an_identity_id) { SecureRandom.uuid }

    let(:request_body) do
      {
        data: {
          attributes: {
            get_an_identity_id:,
          },
        },
      }
    end

    def send_request
      patch url, params: request_body.to_json, headers: { "Content-Type" => "application/json" }
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

      context "when the user has a get an identity ID already" do
        before do
          user.update(get_an_identity_id: SecureRandom.uuid)
        end

        include_examples "correct response check" do
          let(:expected_response_code) { 400 }
          let(:expected_response_body) do
            {
              "errors" => [
                {
                  "status" => "400",
                  "title" => "get_an_identity_id",
                  "detail" => "cannot be changed once set",
                },
              ],
            }
          end
        end

        it "does not update the user" do
          expect {
            send_request
          }.to_not change(user, :as_json)
        end
      end

      context "when the user has not got a get an identity ID" do
        before do
          user.update!(get_an_identity_id: nil)
        end

        context "when the get an identity ID is in use" do
          before do
            create(:user, get_an_identity_id:)
          end

          include_examples "correct response check" do
            let(:expected_response_code) { 400 }
            let(:expected_response_body) do
              {
                "errors" => [
                  {
                    "status" => "400",
                    "title" => "get_an_identity_id",
                    "detail" => "has already been taken",
                  },
                ],
              }
            end
          end

          it "does not update the user" do
            expect {
              send_request
            }.to_not change(user, :as_json)
          end
        end

        context "when the get an identity ID is not in use" do
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
                    "get_an_identity_id" => get_an_identity_id,
                  },
                },
              }
            end
          end

          it "updates the user" do
            expect {
              send_request
            }.to change {
              user.reload.get_an_identity_id
            }.from(nil).to(get_an_identity_id)
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

        it "does not update the user" do
          expect {
            send_request
          }.to_not change(user, :as_json)
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

        it "does not update the user" do
          expect {
            send_request
          }.to_not change(user, :as_json)
        end
      end
    end
  end
end
