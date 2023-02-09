# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantOutcomes::SendToQualifiedTeachersApiJob, :with_default_schedules do
  describe "#perform" do
    let(:participant_declaration) { create :npq_participant_declaration }
    let(:participant_outcome) { create :participant_outcome, participant_declaration: }

    it "executes successfully" do
      expect(described_class.new.perform(participant_outcome)).to eql("actioned")
    end

    it "queues job" do
      expect {
        described_class.perform_later(participant_outcome)
      }.to have_enqueued_job.on_queue("participant_outcomes")
    end
  end
end
