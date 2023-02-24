# frozen_string_literal: true

RSpec.describe QualifiedTeachers::Client, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
  let(:user) { create(:user, full_name: "John Doe") }
  let(:teacher_profile) { create(:teacher_profile, user:, trn: "1234567") }
  let(:participant_profile) { create(:npq_participant_profile, npq_lead_provider:, npq_course:, teacher_profile:, user:) }
  let(:participant_declaration) { create(:npq_participant_declaration, npq_course:, cpd_lead_provider:, participant_profile:) }
  let(:participant_outcome) { create(:participant_outcome, participant_declaration:, completion_date: Time.zone.local(2023, 2, 20, 17, 30, 0).rfc3339) }
  let!(:participant_outcome_id) { participant_outcome.id }
  let(:trn) { participant_outcome.participant_declaration&.participant_profile&.teacher_profile&.trn }
  let(:incorrect_trn) { "1001009" }
  let(:request_body) do
    {
      completionDate: participant_outcome.completion_date.to_s,
      qualificationType: participant_outcome.participant_declaration.qualification_type,
    }
  end
  let(:params) do
    {
      trn:,
      request_body:,
    }
  end

  subject { described_class.new }

  let(:stub_api_request) do
    stub_request(:put, "https://qualified-teachers-api.example.com/v2/npq-qualifications?trn=1234567")
      .with(
        body: "{\"completionDate\":\"2023-02-20\",\"qualificationType\":\"NPQSL\"}",
        headers: {
          "Accept"=>"*/*",
          "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization"=>"Bearer some-apikey-guid",
          "Content-Type"=>"application/json",
          "Host"=>"qualified-teachers-api.example.com",
          "User-Agent"=>"Ruby",
        },
      )
      .to_return(status: 204, body: "", headers: {})
  end

  let(:stub_api_404_request) do
    stub_request(:put, "https://qualified-teachers-api.example.com/v2/npq-qualifications?trn=#{incorrect_trn}")
      .with(
        body: "{\"completionDate\":\"2023-02-20\",\"qualificationType\":\"NPQSL\"}",
        headers: {
          "Accept"=>"*/*",
          "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization"=>"Bearer some-apikey-guid",
          "Content-Type"=>"application/json",
          "Host"=>"qualified-teachers-api.example.com",
          "User-Agent"=>"Ruby",
        },
      )
      .to_return(status: 404, body: { "title": "Teacher with specified TRN not found", "status": 404, "errorCode": 10_001 }.to_json, headers: {})
  end

  let(:stub_api_too_many_requests) do
    stub_request(:put, "https://qualified-teachers-api.example.com/v2/npq-qualifications?trn=1234567")
      .with(
        body: "{\"completionDate\":\"2023-02-20\",\"qualificationType\":\"NPQSL\"}",
        headers: {
          "Accept"=>"*/*",
          "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization"=>"Bearer some-apikey-guid",
          "Content-Type"=>"application/json",
          "Host"=>"qualified-teachers-api.example.com",
          "User-Agent"=>"Ruby",
        },
      )
      .to_return(status: 429, body: "", headers: {})
  end

  let(:stub_api_different_record_request) do
    stub_request(:put, "https://qualified-teachers-api.example.com/v2/npq-qualifications?trn=1234567")
      .with(
        body: "{\"completionDate\":\"2023-02-20\",\"qualificationType\":\"NPQSL\"}",
        headers: {
          "Accept"=>"*/*",
          "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization"=>"Bearer some-apikey-guid",
          "Content-Type"=>"application/json",
          "Host"=>"qualified-teachers-api.example.com",
          "User-Agent"=>"Ruby",
        },
      )
      .to_return(status: 400, body: "", headers: {})
  end

  describe "#send_record" do
    describe "valid request" do
      it "returns success" do
        stub_api_request

        record = subject.send_record(trn:, request_body:)

        expect(record.response.code).to eq("204")
      end
    end

    describe "invalid request" do
      context "when record with given trn does not exist" do
        it "returns error code" do
          stub_api_404_request

          record = subject.send_record(trn: incorrect_trn, request_body:)

          expect(record.response.code).to eq("404")
        end
      end

      context "when api had too many requests" do
        it "raises an exception" do
          stub_api_too_many_requests

          expect { subject.send_record(trn:, request_body:) }.to raise_error(TooManyRequests)
        end
      end

      context "when api had a different error code" do
        it "returns error code" do
          stub_api_different_record_request

          record = subject.send_record(trn:, request_body:)

          expect(record.response.code).to eq("400")
        end
      end
    end
  end
end
