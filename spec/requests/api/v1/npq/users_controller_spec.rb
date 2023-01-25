# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Users", :with_default_schedules, type: :request do
  let(:parsed_response) { JSON.parse(response.body) }
  let(:token)           { NPQRegistrationApiToken.create_with_random_token! }
  let(:bearer_token)    { "Bearer #{token}" }
  let(:authorization_header) { bearer_token }

  describe "#create" do
    let(:url) { "/api/v1/npq/users.json" }

    let(:email)              { "mail@example.com" }
    let(:get_an_identity_id) { SecureRandom.uuid }
    let(:full_name)          { "Jane Smith" }

    let(:request_body) do
      {
        data: {
          attributes: {
            email:,
            get_an_identity_id:,
            full_name:,
          },
        },
      }
    end

    def send_request
      post url, params: request_body.to_json, headers: { "Content-Type" => "application/json" }
    end

    def slice_relevant_user_data(user)
      user.reload.slice(
        :email,
        :get_an_identity_id,
        :full_name,
      ).symbolize_keys
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

      context "when the get_an_identity_id is not in use" do
        context "when the email is not in use" do
          include_examples "correct response check" do
            let(:expected_response_code) { 201 }
            let(:expected_response_body) do
              {
                "data" => {
                  "id" => User.last.id.to_s,
                  "type" => "user",
                  "attributes" => {
                    "email" => email,
                    "full_name" => full_name,
                    "get_an_identity_id" => get_an_identity_id,
                  },
                },
              }
            end
          end

          it "creates a new user" do
            expect {
              send_request
            }.to change {
              {
                user_count: User.count,
                correct_data_saved: User.where(email:, get_an_identity_id:, full_name:).present?,
              }
            }.from(
              {
                user_count: 0,
                correct_data_saved: false,
              },
            ).to(
              {
                user_count: 1,
                correct_data_saved: true,
              },
            )
          end

          context "without a full_name" do
            let(:full_name) { nil }

            include_examples "correct response check" do
              let(:expected_response_code) { 401 }
              let(:expected_response_body) do
                {
                  "errors" => [
                    {
                      "detail" => "Enter a full name",
                      "status" => "401",
                      "title" => "full_name",
                    },
                  ],
                }
              end
            end

            it "does not create a new user" do
              expect {
                send_request
              }.to_not change {
                {
                  user_count: User.count,
                }
              }
            end
          end
        end

        context "when the email is in use by a user without a get_an_identity_id" do
          let!(:pre_existing_user_with_email) do
            create(:user, email:, get_an_identity_id: nil, full_name: "Jane Fletcher")
          end

          include_examples "correct response check" do
            let(:expected_response_code) { 200 }
            let(:expected_response_body) do
              {
                "data" => {
                  "id" => pre_existing_user_with_email.id.to_s,
                  "type" => "user",
                  "attributes" => {
                    "email" => email,
                    "full_name" => full_name,
                    "get_an_identity_id" => get_an_identity_id,
                  },
                },
              }
            end
          end

          it "updates the existing user with get_an_identity_id and full_name" do
            expect {
              send_request
            }.to change {
              {
                user_count: User.count,
                existing_user_details: slice_relevant_user_data(pre_existing_user_with_email),
              }
            }.from(
              {
                user_count: 1,
                existing_user_details: {
                  email:,
                  get_an_identity_id: nil,
                  full_name: "Jane Fletcher",
                },
              },
            ).to(
              {
                user_count: 1,
                existing_user_details: {
                  email:,
                  get_an_identity_id:,
                  full_name:,
                },
              },
            )
          end
        end

        context "when the email is in use by a user with a different get_an_identity_id" do
          let!(:pre_existing_user_with_email) do
            create(:user, email:, get_an_identity_id: SecureRandom.uuid, full_name: "Jane Fletcher")
          end

          include_examples "correct response check" do
            let(:expected_response_code) { 401 }
            let(:expected_response_body) do
              {
                "errors" => [
                  {
                    "status" => "401",
                    "title" => "get_an_identity_id",
                    "detail" => "could not be persisted as user with matching email address already has a different get_an_identity_id",
                  },
                ],
              }
            end
          end

          it "does not update the existing user" do
            expect {
              send_request
            }.to_not change {
              {
                user_count: User.count,
                existing_user_details: slice_relevant_user_data(pre_existing_user_with_email),
              }
            }
          end
        end

        context "when no email is sent" do
          let(:email) { nil }

          include_examples "correct response check" do
            let(:expected_response_code) { 401 }
            let(:expected_response_body) do
              {
                "errors" => [
                  {
                    "status" => "401",
                    "title" => "email",
                    "detail" => "is required",
                  },
                ],
              }
            end
          end

          it "does not create a user" do
            expect {
              send_request
            }.to_not change {
              {
                user_count: User.count,
              }
            }
          end
        end
      end

      context "when the get_an_identity_id is in use" do
        let!(:pre_existing_user_with_get_an_identity_id) do
          create(:user, email: pre_existing_user_with_get_an_identity_id_email, get_an_identity_id:, full_name: "Jane Fletcher")
        end
        let(:pre_existing_user_with_get_an_identity_id_email) { "mail2@example.com" }

        context "when the email is in use by the same user" do
          let(:pre_existing_user_with_get_an_identity_id_email) { email }

          include_examples "correct response check" do
            let(:expected_response_code) { 200 }
            let(:expected_response_body) do
              {
                "data" => {
                  "id" => pre_existing_user_with_get_an_identity_id.id.to_s,
                  "type" => "user",
                  "attributes" => {
                    "email" => email,
                    "full_name" => full_name,
                    "get_an_identity_id" => get_an_identity_id,
                  },
                },
              }
            end
          end

          it "updates the existing user with full_name" do
            expect {
              send_request
            }.to change {
              {
                user_count: User.count,
                existing_user_details: slice_relevant_user_data(pre_existing_user_with_get_an_identity_id),
              }
            }.from(
              {
                user_count: 1,
                existing_user_details: {
                  email:,
                  get_an_identity_id:,
                  full_name: "Jane Fletcher",
                },
              },
            ).to(
              {
                user_count: 1,
                existing_user_details: {
                  email:,
                  get_an_identity_id:,
                  full_name:,
                },
              },
            )
          end
        end

        context "when the email is in use by a different user without a get_an_identity_id" do
          let!(:pre_existing_user_with_email) do
            create(:user, email:, get_an_identity_id: nil)
          end

          include_examples "correct response check" do
            let(:expected_response_code) { 401 }
            let(:expected_response_body) do
              {
                "errors" => [
                  {
                    "status" => "401",
                    "title" => "email",
                    "detail" => "could not be updated on user with get_an_identity_id as email taken on another user",
                  },
                ],
              }
            end
          end

          it "does not update the existing users" do
            expect {
              send_request
            }.to_not change {
              {
                user_count: User.count,
                existing_user_details: [
                  slice_relevant_user_data(pre_existing_user_with_email),
                  slice_relevant_user_data(pre_existing_user_with_get_an_identity_id),
                ],
              }
            }
          end
        end

        context "when the email is in use by a different user with a get_an_identity_id" do
          let!(:pre_existing_user_with_email) do
            create(:user, email:, get_an_identity_id: SecureRandom.uuid)
          end

          include_examples "correct response check" do
            let(:expected_response_code) { 401 }
            let(:expected_response_body) do
              {
                "errors" => [
                  {
                    "status" => "401",
                    "title" => "email",
                    "detail" => "could not be updated on user with get_an_identity_id as email taken on another user",
                  },
                ],
              }
            end
          end

          it "does not update the existing users" do
            expect {
              send_request
            }.to_not change {
              {
                user_count: User.count,
                existing_user_details: [
                  slice_relevant_user_data(pre_existing_user_with_email),
                  slice_relevant_user_data(pre_existing_user_with_get_an_identity_id),
                ],
              }
            }
          end
        end

        context "when the email is not in use" do
          include_examples "correct response check" do
            let(:expected_response_code) { 200 }
            let(:expected_response_body) do
              {
                "data" => {
                  "id" => pre_existing_user_with_get_an_identity_id.id.to_s,
                  "type" => "user",
                  "attributes" => {
                    "email" => email,
                    "full_name" => full_name,
                    "get_an_identity_id" => get_an_identity_id,
                  },
                },
              }
            end
          end

          it "updates the existing user with email and full_name" do
            expect {
              send_request
            }.to change {
              {
                user_count: User.count,
                existing_user_details: slice_relevant_user_data(pre_existing_user_with_get_an_identity_id),
              }
            }.from(
              {
                user_count: 1,
                existing_user_details: {
                  email: "mail2@example.com",
                  get_an_identity_id:,
                  full_name: "Jane Fletcher",
                },
              },
            ).to(
              {
                user_count: 1,
                existing_user_details: {
                  email:,
                  get_an_identity_id:,
                  full_name:,
                },
              },
            )
          end
        end

        context "when no email is sent" do
          let(:email) { nil }

          include_examples "correct response check" do
            let(:expected_response_code) { 401 }
            let(:expected_response_body) do
              {
                "errors" => [
                  {
                    "status" => "401",
                    "title" => "email",
                    "detail" => "is required",
                  },
                ],
              }
            end
          end

          it "does not create a user" do
            expect {
              send_request
            }.to_not change {
              {
                user_count: User.count,
              }
            }
          end
        end
      end

      context "when no get_an_identity_id is sent" do
        let(:get_an_identity_id) { nil }

        context "when the email is not in use" do
          include_examples "correct response check" do
            let(:expected_response_code) { 201 }
            let(:expected_response_body) do
              {
                "data" => {
                  "id" => User.last.id.to_s,
                  "type" => "user",
                  "attributes" => {
                    "email" => email,
                    "full_name" => full_name,
                    "get_an_identity_id" => get_an_identity_id,
                  },
                },
              }
            end
          end

          it "creates a new user" do
            expect {
              send_request
            }.to change {
              {
                user_count: User.count,
                correct_data_saved: User.where(email:, get_an_identity_id:, full_name:).present?,
              }
            }.from(
              {
                user_count: 0,
                correct_data_saved: false,
              },
            ).to(
              {
                user_count: 1,
                correct_data_saved: true,
              },
            )
          end

          context "without a full_name" do
            let(:full_name) { nil }

            include_examples "correct response check" do
              let(:expected_response_code) { 401 }
              let(:expected_response_body) do
                {
                  "errors" => [
                    {
                      "detail" => "Enter a full name",
                      "status" => "401",
                      "title" => "full_name",
                    },
                  ],
                }
              end
            end

            it "does not create a new user" do
              expect {
                send_request
              }.to_not change {
                {
                  user_count: User.count,
                }
              }
            end
          end
        end

        context "when the email is in use by a user without a get_an_identity_id" do
          let!(:pre_existing_user_with_email) do
            create(:user, email:, get_an_identity_id: nil, full_name: "Jane Fletcher")
          end

          include_examples "correct response check" do
            let(:expected_response_code) { 200 }
            let(:expected_response_body) do
              {
                "data" => {
                  "id" => pre_existing_user_with_email.id.to_s,
                  "type" => "user",
                  "attributes" => {
                    "email" => email,
                    "full_name" => full_name,
                    "get_an_identity_id" => get_an_identity_id,
                  },
                },
              }
            end
          end

          it "updates the existing user with full_name" do
            expect {
              send_request
            }.to change {
              {
                user_count: User.count,
                existing_user_details: slice_relevant_user_data(pre_existing_user_with_email),
              }
            }.from(
              {
                user_count: 1,
                existing_user_details: {
                  email:,
                  get_an_identity_id: nil,
                  full_name: "Jane Fletcher",
                },
              },
            ).to(
              {
                user_count: 1,
                existing_user_details: {
                  email:,
                  get_an_identity_id:,
                  full_name:,
                },
              },
            )
          end
        end

        context "when the email is in use by a user with a get_an_identity_id" do
          let!(:pre_existing_user_with_email) do
            create(:user, email:, get_an_identity_id: SecureRandom.uuid, full_name: "Jane Fletcher")
          end

          include_examples "correct response check" do
            let(:expected_response_code) { 401 }
            let(:expected_response_body) do
              {
                "errors" => [
                  {
                    "status" => "401",
                    "title" => "email",
                    "detail" => "lookup failed as user with matching email has get_an_identity_id and none was sent",
                  },
                ],
              }
            end
          end

          it "does not update the existing user" do
            expect {
              send_request
            }.to_not change {
              {
                user_count: User.count,
                existing_user_details: slice_relevant_user_data(pre_existing_user_with_email),
              }
            }
          end
        end

        context "when no email is sent" do
          let(:email) { nil }

          include_examples "correct response check" do
            let(:expected_response_code) { 401 }
            let(:expected_response_body) do
              {
                "errors" => [
                  {
                    "status" => "401",
                    "title" => "email",
                    "detail" => "is required",
                  },
                ],
              }
            end
          end

          it "does not create a user" do
            expect {
              send_request
            }.to_not change {
              {
                user_count: User.count,
              }
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

        it "does not a new user" do
          expect {
            send_request
          }.to_not change(User, :count)
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

        it "does not a new user" do
          expect {
            send_request
          }.to_not change(User, :count)
        end
      end
    end
  end
end
