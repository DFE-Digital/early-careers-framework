# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::StreamBigQueryEnrollmentJob do
  let(:npq_validation_data) { create(:npq_validation_data) }

  describe "#perform" do
    let(:bigquery) { double("bigquery") }
    let(:dataset) { double("dataset") }
    let(:table) { double("table", insert: nil) }

    before do
      allow(Google::Cloud::Bigquery).to receive(:new).and_return(bigquery)
      allow(bigquery).to receive(:dataset).and_return(dataset)
      allow(dataset).to receive(:table).and_return(table)
    end

    it "sends correct data to BigQuery" do
      described_class.perform_now(npq_validation_data_id: npq_validation_data.id)

      expect(table).to have_received(:insert).with([{
        "application_ecf_id" => npq_validation_data.id,
        "status" => "pending",
        "updated_at" => npq_validation_data.updated_at,
      }])
    end
  end
end
