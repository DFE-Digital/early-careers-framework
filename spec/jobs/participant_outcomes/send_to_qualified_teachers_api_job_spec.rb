# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantOutcomes::SendToQualifiedTeachersApiJob, :with_default_schedules do
  describe "#perform" do
    let(:participant_declaration) { create :npq_participant_declaration }
    let(:participant_outcome) { create :participant_outcome, participant_declaration: }
    let!(:participant_outcome_id) { participant_outcome.id }

    subject(:job) { described_class.perform_now(participant_outcome_id:) }

    let(:api_sender) { double }
    let(:response) { double(status: 200, body: "Testing") }

    before do
      allow(QualifiedTeachersApiSender).to receive(:new).with(participant_outcome_id:).and_return(api_sender)
      allow(api_sender).to receive(:call).and_return(response)
    end

    it "calls the correct service class" do
      expect(api_sender).to receive(:call).and_return(response)

      job
    end
  end
end
