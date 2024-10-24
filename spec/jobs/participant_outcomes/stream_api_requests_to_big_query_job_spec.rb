# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantOutcomes::StreamApiRequestsToBigQueryJob do
  let(:participant_outcome_api_request) { create(:participant_outcome_api_request, :with_trn_success) }
  let(:participant_outcome_api_request_id) { participant_outcome_api_request.id }

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
      described_class.perform_now(participant_outcome_api_request_id:)

      expect(table).to have_received(:insert).with([{
        participant_outcome_api_request_id: participant_outcome_api_request.id,
          request_path: participant_outcome_api_request.request_path,
          status_code: participant_outcome_api_request.status_code,
          request_headers: participant_outcome_api_request.request_headers.to_json,
          request_body: participant_outcome_api_request.request_body.to_json,
          response_body: participant_outcome_api_request.response_body.to_json,
          response_headers: participant_outcome_api_request.response_headers.to_json,
          participant_outcome_id: participant_outcome_api_request.participant_outcome_id,
          created_at: participant_outcome_api_request.created_at,
          updated_at: participant_outcome_api_request.updated_at,
      }.stringify_keys], ignore_unknown: true)
    end

    it "enqueues job" do
      expect {
        described_class.perform_now(participant_outcome_api_request_id:)
      }.to have_enqueued_job(described_class).on_queue("big_query")
    end

    context "where the BigQuery table does not exist" do
      before do
        allow(dataset).to receive(:table).and_return(nil)
      end

      it "doesn't attempt to stream" do
        described_class.perform_now(participant_outcome_api_request_id:)
        expect(table).not_to have_received(:insert)
      end
    end

    context "when `disable_npq` feature flag is active" do
      let(:participant_outcome_api_request_id) { SecureRandom.uuid }

      before { FeatureFlag.activate(:disable_npq) }

      it "returns nil" do
        expect(described_class.perform_now(participant_outcome_api_request_id:)).to be_nil
      end

      it "doesn't attempt to stream" do
        described_class.perform_now(participant_outcome_api_request_id:)

        expect(table).not_to have_received(:insert)
      end
    end
  end
end
