# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantOutcomes::BatchSendLatestOutcomesJob do
  let(:outcome_1) { double(id: 1) }
  let(:outcome_2) { double(id: 2) }
  let(:outcomes) { [outcome_1, outcome_2] }

  before do
    allow(ParticipantOutcome::NPQ).to receive(:to_send_to_qualified_teachers_api).and_return(outcomes)
  end

  describe "#perform" do
    context "when there are already instances of SendToQualifiedTeachersApiJob in the job queue" do
      before { ParticipantOutcomes::SendToQualifiedTeachersApiJob.set(wait_until: 1.year.from_now).perform_later(1) }

      it "requeues itself" do
        expect { described_class.perform_now }.to have_enqueued_job(described_class)
      end
    end

    context "when there are no more than batch_size records" do
      let(:batch_size) { 2 }

      it "does not requeue itself" do
        expect { described_class.perform_now(batch_size) }.not_to have_enqueued_job(described_class)
      end

      it "enqueues the send job for each record" do
        described_class.perform_now

        expect(ParticipantOutcomes::SendToQualifiedTeachersApiJob).to(have_been_enqueued.exactly(:once).with(1))
        expect(ParticipantOutcomes::SendToQualifiedTeachersApiJob).to(have_been_enqueued.exactly(:once).with(2))
      end
    end

    context "when there are more than batch_size records" do
      let(:batch_size) { 1 }

      it "requeues itself" do
        expect { described_class.perform_now(batch_size) }.to have_enqueued_job(described_class)
      end

      it "only enqueues the send job for the first records up to the batch_size" do
        described_class.perform_now(batch_size)

        expect(ParticipantOutcomes::SendToQualifiedTeachersApiJob).to have_been_enqueued.exactly(:once).with(1)
        expect(ParticipantOutcomes::SendToQualifiedTeachersApiJob).not_to have_been_enqueued.with(2)
      end
    end
  end

  describe "#perform_later" do
    it "enqueues the job" do
      expect { described_class.perform_later }.to have_enqueued_job(described_class).on_queue("participant_outcomes")
    end
  end
end
