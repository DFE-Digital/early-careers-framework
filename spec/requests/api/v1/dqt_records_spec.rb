# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DQT records api endpoint", type: :request do
  describe "#show" do
    let(:token) { NpqRegistrationApiToken.create_with_random_token! }
    let(:bearer_token) { "Bearer #{token}" }
    let(:trn) { "1000000" }
    let(:parsed_response) { JSON.parse(response.body) }
    let(:mock_client) { instance_double("Dqt::Client.new") }
    let(:hash_response) do
      {
        teacher_reference_number: "1000000",
        full_name: "John Doe",
        date_of_birth: 40.years.ago,
        national_insurance_number: "AB123456C",
        qts_date: 10.years.ago,
        active_alert: false,
      }
    end

    before do
      allow(mock_client).to receive_message_chain("api.dqt_record.show") { hash_response }
      allow(Dqt::Client).to receive(:new).and_return(mock_client)
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct jsonapi content type header" do
        get "/api/v1/dqt-records/#{trn}"
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "returns correct type" do
        get "/api/v1/dqt-records/#{trn}"
        expect(parsed_response["data"]).to have_type("dqt_record")
      end

      it "has correct attributes" do
        get "/api/v1/dqt-records/#{trn}"

        expect(parsed_response["data"]["id"]).to eql(hash_response[:teacher_reference_number])
        expect(parsed_response["data"]).to have_jsonapi_attributes(:teacher_reference_number, :full_name, :date_of_birth, :national_insurance_number, :qts_date, :active_alert).exactly
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v1/dqt-records/#{trn}"
        expect(response.status).to eq 401
      end
    end
  end
end
