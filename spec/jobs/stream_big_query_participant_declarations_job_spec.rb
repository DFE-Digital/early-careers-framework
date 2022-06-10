# frozen_string_literal: true

require "rails_helper"

RSpec.describe StreamBigQueryParticipantDeclarationsJob, :with_default_schedules do
  let!(:streamable_declaration) { travel_to(1.hour.ago) { create(:ect_participant_declaration) } }
  let(:cpd_lead_provider)       { streamable_declaration.cpd_lead_provider }
  before do
    travel_to(2.hours.ago) { create(:ect_participant_declaration) }
    create(:ect_participant_declaration)
  end

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
      described_class.perform_now

      expect(table).to have_received(:insert).with([
        streamable_declaration.attributes.merge(
          "cpd_lead_provider_name" => cpd_lead_provider.name,
        ),
      ], { ignore_unknown: true })
    end

    it "doesn't attempt to stream when there are no updates" do
      ParticipantDeclaration.update_all(updated_at: 2.hours.ago)
      described_class.perform_now
      expect(table).not_to have_received(:insert)
    end

    context "where the BigQuery table does not exist" do
      before do
        allow(dataset).to receive(:table).and_return(nil)
      end

      it "doesn't attempt to stream" do
        ParticipantDeclaration.update_all(updated_at: 0.5.hours.ago)
        described_class.perform_now
        expect(table).not_to have_received(:insert)
      end
    end
  end
end
