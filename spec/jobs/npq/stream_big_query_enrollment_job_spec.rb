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
    allow(Google::Cloud::Bigquery).to receive(:new).and_return(bigquery)
    allow(bigquery).to receive(:dataset).and_return(dataset)
    allow(dataset).to receive(:table).and_return(table)
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

    context "when there is no cohort" do
      let(:npq_application) { create(:npq_application, cohort: nil, employment_role:, employer_name:) }

      it "sends correct data to BigQuery" do
        described_class.perform_now(npq_application_id: npq_application.id)

        expect(table).to have_received(:insert).with([{
          "application_ecf_id" => npq_application.id,
          "cohort" => nil,
          "status" => "pending",
          "updated_at" => npq_application.updated_at,
          "employer_name" => employer_name,
          "employment_role" => employment_role,
        }], ignore_unknown: true)
      end
    end

    context "where the BigQuery table does not exist" do
      before do
        allow(dataset).to receive(:table).and_return(nil)
      end

      it "doesn't attempt to stream" do
        described_class.perform_now(npq_application_id: npq_application.id)
        expect(table).not_to have_received(:insert)
      end
    end
  end
end
