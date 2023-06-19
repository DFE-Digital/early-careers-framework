# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantOutcomeApiRequest, :with_default_schedules, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:participant_outcome).class_name("ParticipantOutcome::NPQ") }
  end

  describe "#push_to_big_query" do
    let(:api_request) { create(:participant_outcome_api_request, :with_trn_success) }

    context "on create" do
      it "pushes attributes to BigQuery" do
        allow(ParticipantOutcomes::StreamApiRequestsToBigQueryJob).to receive(:perform_later).and_call_original
        api_request
        expect(ParticipantOutcomes::StreamApiRequestsToBigQueryJob).to have_received(:perform_later).with(participant_outcome_api_request_id: api_request.id)
      end
    end

    context "on update" do
      it "pushes attributes to BigQuery" do
        allow(ParticipantOutcomes::StreamApiRequestsToBigQueryJob).to receive(:perform_later).and_call_original
        api_request
        api_request.update!(status_code: 200)
        expect(ParticipantOutcomes::StreamApiRequestsToBigQueryJob).to have_received(:perform_later).with(participant_outcome_api_request_id: api_request.id).twice
      end
    end
  end
end
