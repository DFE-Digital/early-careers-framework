# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantOutcomes::BatchSendLatestOutcomesJob do
  let(:outcome_1) { double(id: 1) }
  let(:outcome_2) { double(id: 2) }
  let(:outcomes) { [outcome_1, outcome_2] }
  let(:default_batch_size) { described_class::DEFAULT_BATCH_SIZE }
  let(:queue_double) { double(detect: nil) }

  before do
    allow(ParticipantOutcome::NPQ).to receive(:to_send_to_qualified_teachers_api).and_return(outcomes)
    allow(Sidekiq::Queue).to receive(:new).with("participant_outcomes").and_return(queue_double)
  end

  describe "#perform" do
    context "when there are no more than batch_size records" do
      let(:batch_size) { 2 }

      it "enqueues the send job for each record" do
        described_class.perform_now

        expect(ParticipantOutcomes::SendToQualifiedTeachersApiJob).to(have_been_enqueued.exactly(:once).with(participant_outcome_id: 1))
        expect(ParticipantOutcomes::SendToQualifiedTeachersApiJob).to(have_been_enqueued.exactly(:once).with(participant_outcome_id: 2))
      end
    end

    context "when there are more than batch_size records" do
      let(:batch_size) { 1 }

      it "only enqueues the send job for the first records up to the batch_size" do
        described_class.perform_now(batch_size)

        expect(ParticipantOutcomes::SendToQualifiedTeachersApiJob).to have_been_enqueued.exactly(:once).with(participant_outcome_id: 1)
        expect(ParticipantOutcomes::SendToQualifiedTeachersApiJob).not_to have_been_enqueued.with(participant_outcome_id: 2)
      end
    end

    it "does not requeue itself" do
      expect { described_class.perform_now(default_batch_size) }.not_to have_enqueued_job(described_class)
    end
  end

  describe "#perform_later" do
    it "enqueues the job" do
      expect { described_class.perform_later }.to have_enqueued_job(described_class).on_queue("participant_outcomes")
    end
  end
end
