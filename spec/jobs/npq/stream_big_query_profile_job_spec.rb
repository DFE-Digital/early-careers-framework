# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::StreamBigQueryProfileJob do
  let(:profile) { create(:npq_participant_profile) }

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
      described_class.perform_now(profile_id: profile.id)

      expect(table).to have_received(:insert).with([{
        profile_id: profile.id,
        user_id: profile.participant_identity.user_id,
        external_id: profile.participant_identity.external_identifier,
        application_ecf_id: profile.npq_application&.id,
        status: profile.status,
        training_status: profile.training_status,
        schedule_identifier: profile.schedule&.schedule_identifier,
        course_identifier: profile.npq_course.identifier,
        created_at: profile.created_at,
        updated_at: profile.updated_at,
      }.stringify_keys], ignore_unknown: true)
    end

    context "where the BigQuery table does not exist" do
      before do
        allow(dataset).to receive(:table).and_return(nil)
      end

      it "doesn't attempt to stream" do
        described_class.perform_now(profile_id: profile.id)
        expect(table).not_to have_received(:insert)
      end
    end
  end
end
