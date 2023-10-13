# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::ResendParticipantOutcome do
  let(:participant_outcome) { create(:participant_outcome, :unsuccessfully_sent_to_qualified_teachers_api) }
  let!(:participant_outcome_id) { participant_outcome.id }

  let(:params) do
    {
      participant_outcome_id:,
    }
  end

  subject(:service) { described_class.new(params) }

  describe "#call" do
    context "when the participant outcome id is missing" do
      let(:participant_outcome_id) {}

      it "is invalid" do
        is_expected.to be_invalid
      end
    end

    context "when participant outcome has already been sent" do
      let(:participant_outcome) { create(:participant_outcome, :successfully_sent_to_qualified_teachers_api) }

      it "is invalid" do
        is_expected.to be_invalid
      end
    end

    it "is valid" do
      is_expected.to be_valid
    end

    it "updates the participant outcome" do
      expect {
        service.call
      }.to change {
        participant_outcome.reload.qualified_teachers_api_request_successful
      }.to(nil).and change {
        participant_outcome.reload.sent_to_qualified_teachers_api_at
      }.to(nil)
    end
  end
end
