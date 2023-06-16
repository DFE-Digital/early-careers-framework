# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantOutcomes::StreamBigQueryJob, :with_default_schedules do
  let(:participant_declaration) { create(:npq_participant_declaration) }
  let(:outcome) { create(:participant_outcome, :sent_to_qualified_teachers_api, participant_declaration:, qualified_teachers_api_request_successful: true) }

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
      freeze_time do
        described_class.perform_now(participant_outcome_id: outcome.id)

        expect(table).to have_received(:insert).with([{
          participant_outcome_id: outcome.id,
          state: outcome.state,
          completion_date: outcome.completion_date,
          participant_declaration_id: outcome.participant_declaration_id,
          created_at: outcome.created_at,
          updated_at: outcome.updated_at,
          qualified_teachers_api_request_successful: outcome.qualified_teachers_api_request_successful,
          sent_to_qualified_teachers_api_at: outcome.sent_to_qualified_teachers_api_at,
        }.stringify_keys], ignore_unknown: true)
      end
    end

    it "queues job" do
      expect {
        described_class.perform_now(participant_outcome_id: outcome.id)
      }.to have_enqueued_job(described_class).on_queue("big_query")
    end
  end
end
