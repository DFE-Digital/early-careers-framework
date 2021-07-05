# frozen_string_literal: true

require "rails_helper"

RSpec.describe "participant validation api endpoint", type: :request do
  describe "#show" do
    let(:token) { NpqRegistrationApiToken.create_with_random_token! }
    let(:bearer_token) { "Bearer #{token}" }
    let(:parsed_response) { JSON.parse(response.body) }
    let(:trn) { rand(1_000_000..9_999_999).to_s }
    let(:full_name) { "John Doe" }
    let(:date_of_birth) { rand(50.years.ago..20.years.ago).to_date }
    let(:nino) { "AB123456C" }

    let(:service_response) do
      {
        trn: trn,
        qts: "1999-12-13",
        active_alert: false,
      }
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token

        allow(ParticipantValidationService).to receive(:validate).and_return(service_response)
      end

      it "returns correct jsonapi content type header" do
        get "/api/v1/participant-validation/#{trn}?full_name=#{full_name}&date_of_birth=#{date_of_birth}&nino=#{nino}"
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "returns correct type" do
        get "/api/v1/participant-validation/#{trn}?full_name=#{full_name}&date_of_birth=#{date_of_birth}&nino=#{nino}"
        expect(parsed_response["data"]).to have_type("participant_validation")
      end

      it "has correct attributes" do
        get "/api/v1/participant-validation/#{trn}?full_name=#{full_name}&date_of_birth=#{date_of_birth}&nino=#{nino}"

        expect(parsed_response["data"]["id"]).to eql(service_response[:trn])
        expect(parsed_response["data"]).to have_jsonapi_attributes(:trn, :qts, :active_alert).exactly
      end

      context "when no record is found for given teacher_reference_number" do
        let(:service_response) { nil }

        it "returns a 404" do
          get "/api/v1/participant-validation/#{trn}?full_name=#{full_name}&date_of_birth=#{date_of_birth}&nino=#{nino}"
          expect(response).to be_not_found
        end
      end
    end

    context "when unauthorized" do
      it "returns 401" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v1/participant-validation/#{trn}?full_name=#{full_name}&date_of_birth=#{date_of_birth}&nino=#{nino}"
        expect(response.status).to eq 401
      end
    end

    context "using valid token but for different scope" do
      let(:other_token) { ApiToken.create_with_random_token! }

      it "returns 403" do
        default_headers[:Authorization] = "Bearer #{other_token}"
        get "/api/v1/participant-validation/#{trn}?full_name=#{full_name}&date_of_birth=#{date_of_birth}&nino=#{nino}"
        expect(response.status).to eq 403
      end
    end
  end
end
