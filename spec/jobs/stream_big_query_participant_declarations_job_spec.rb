# frozen_string_literal: true

require "rails_helper"

require_relative "../shared/context/service_record_declaration_params"
require_relative "../shared/context/lead_provider_profiles_and_courses"

RSpec.describe StreamBigQueryParticipantDeclarationsJob do
  include_context "lead provider profiles and courses"
  include_context "service record declaration params"

  let(:valid_updated_at) { 1.hour.ago }
  let!(:streamable_declaration) do
    create(:participant_declaration,
           cpd_lead_provider: cpd_lead_provider,
           participant_profile: ect_profile,
           course_identifier: "ecf-induction",
           declaration_date: Time.zone.parse("10/10/2021"),
           updated_at: valid_updated_at)
  end
  let!(:other_declarations) do
    [
      create(:participant_declaration, participant_profile: ect_profile, course_identifier: "ecf-induction"), # updated this hour
      create(:participant_declaration, updated_at: 2.hours.ago, participant_profile: ect_profile, course_identifier: "ecf-induction"), # updated 1+ hours ago
    ]
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
      ])
    end
  end
end
