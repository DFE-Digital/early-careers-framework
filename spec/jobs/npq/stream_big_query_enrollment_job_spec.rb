# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::StreamBigQueryEnrollmentJob do
  let(:employer_name)   { "john doe" }
  let(:employment_role) { "teacher" }
  let(:npq_application) { create(:npq_application, employment_role:, employer_name:) }

  let(:bigquery) { instance_double(Google::Cloud::Bigquery::Project) }
  let(:dataset)  { instance_double(Google::Cloud::Bigquery::Dataset) }
  let(:table)    { instance_double(Google::Cloud::Bigquery::Table, insert: nil) }

  before do
    expect(Google::Cloud::Bigquery).to receive(:new).and_return(bigquery)
    expect(bigquery)
      .to receive(:dataset).with("npq_registration", skip_lookup: true).and_return(dataset)
    expect(dataset)
      .to receive(:table).with("enrollments_test", skip_lookup: true).and_return(table)
  end

  describe "#perform" do
    it "sends correct data to BigQuery" do
      described_class.perform_now(npq_application_id: npq_application.id)

      expect(table).to have_received(:insert).with([{
        "application_ecf_id" => npq_application.id,
        "cohort" => npq_application.cohort.start_year,
        "status" => "pending",
        "updated_at" => npq_application.updated_at,
        "employer_name" => employer_name,
        "employment_role" => employment_role,
      }], ignore_unknown: true)
    end
  end
end
