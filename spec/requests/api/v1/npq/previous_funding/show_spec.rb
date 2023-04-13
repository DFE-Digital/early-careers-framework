# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NPQ Funding API", type: :request do
  let(:token) { NPQRegistrationApiToken.create_with_random_token!(private_api_access: true) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body) }

  let(:base_url) { "/api/v1/npq/previous_funding" }

  let(:npq_course_identifier) { "npq-leading-literacy" }
  let(:trn) { "1234567" }
  let(:get_an_identity_id) { "87654321" }

  def stub_funding_eligibility_response(trn: nil, get_an_identity_id: nil, npq_course_identifier: nil)
    stubbed_response = {
      "previously_funded" => SecureRandom.uuid,
      "previously_received_targeted_funding_support" => SecureRandom.uuid,
    }

    stubbed_checker = double(:npq_funding_eligibility)
    allow(stubbed_checker).to receive(:call).and_return(stubbed_response)
    expect(NPQ::FundingEligibility).to receive(:new)
                                         .with({ get_an_identity_id:, trn:, npq_course_identifier: })
                                         .and_return(stubbed_checker)

    stubbed_response
  end

  describe "GET /api/v1/npq/previous_funding" do
    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      context "with no identifiers" do
        it "returns an error" do
          get "#{base_url}?npq_course_identifier=#{npq_course_identifier}"

          expect(parsed_response).to eq({
            "error" => "No user identifier provided. Valid identifier params: trn or get_an_identity_id",
          })
          expect(response.status).to eq 400
        end
      end

      context "with trn" do
        it "returns response from NPQ::FundingEligibility" do
          stubbed_response = stub_funding_eligibility_response(
            trn:,
            npq_course_identifier: "npq-leading-literacy",
          )

          get "#{base_url}?trn=#{trn}&npq_course_identifier=#{npq_course_identifier}"

          expect(parsed_response).to eq(stubbed_response)
        end

        context "with get_an_identity_id" do
          it "returns correct response" do
            stubbed_response = stub_funding_eligibility_response(
              trn:,
              get_an_identity_id:,
              npq_course_identifier: "npq-leading-literacy",
            )

            get "#{base_url}?trn=#{trn}&get_an_identity_id=#{get_an_identity_id}&npq_course_identifier=#{npq_course_identifier}"

            expect(parsed_response).to eq(stubbed_response)
          end
        end

        context "with no npq_course_identifier" do
          it "returns an error" do
            get "#{base_url}?trn=#{trn}"

            expect(parsed_response).to eq({
              "error" => "No npq_course_identifier provided",
            })
            expect(response.status).to eq 400
          end
        end
      end

      context "with get_an_identity_id" do
        before do
          default_headers[:Authorization] = bearer_token
        end

        it "returns correct response" do
          stubbed_response = stub_funding_eligibility_response(
            get_an_identity_id:,
            npq_course_identifier: "npq-leading-literacy",
          )

          get "#{base_url}?get_an_identity_id=#{get_an_identity_id}&npq_course_identifier=#{npq_course_identifier}"

          expect(parsed_response).to eq(stubbed_response)
        end

        context "with no npq_course_identifier" do
          it "returns an error" do
            get "#{base_url}?get_an_identity_id=#{get_an_identity_id}"

            expect(parsed_response).to eq({
              "error" => "No npq_course_identifier provided",
            })
            expect(response.status).to eq 400
          end
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get base_url
        expect(response.status).to eq 401
      end
    end
  end
end
