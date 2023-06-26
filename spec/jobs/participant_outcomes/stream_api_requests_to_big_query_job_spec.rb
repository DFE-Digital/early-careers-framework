# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantOutcomes::StreamApiRequestsToBigQueryJob, :with_default_schedules do
  let(:api_request) { create(:participant_outcome_api_request, :with_trn_success) }

  describe "#perform" do
    let(:bigquery) { double("bigquery") }
    let(:dataset)  { double("dataset") }
    let(:table)    { double("table", insert: nil) }

    before do
      allow(Google::Cloud::Bigquery).to receive(:new).and_return(bigquery)
      allow(bigquery).to receive(:dataset).and_return(dataset)
      allow(dataset).to receive(:table).and_return(table)
    end

    it "sends correct data to BigQuery" do
      described_class.perform_now(participant_outcome_api_request_id: api_request.id)

      expect(table).to have_received(:insert).with([{
        participant_outcome_api_request_id: api_request.id,
          request_path: api_request.request_path,
          status_code: api_request.status_code,
          request_headers: api_request.request_headers.to_json,
          request_body: api_request.request_body.to_json,
          response_body: api_request.response_body.to_json,
          response_headers: api_request.response_headers.to_json,
          participant_outcome_id: api_request.participant_outcome_id,
          created_at: api_request.created_at,
          updated_at: api_request.updated_at,
      }.stringify_keys], ignore_unknown: true)
    end

    it "queues job" do
      expect {
        described_class.perform_now(participant_outcome_api_request_id: api_request.id)
      }.to have_enqueued_job(described_class).on_queue("big_query")
    end

    context "where the BigQuery table does not exist" do
      before do
        allow(dataset).to receive(:table).and_return(nil)
      end

      it "doesn't attempt to stream" do
        described_class.perform_now(participant_outcome_api_request_id: api_request.id)
        expect(table).not_to have_received(:insert)
      end
    end
  end
end
