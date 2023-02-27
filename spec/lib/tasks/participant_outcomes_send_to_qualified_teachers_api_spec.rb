# frozen_string_literal: true

RSpec.describe "rake participant_outcomes:send_to_qualified_teachers_api", type: :task do
  let(:default_batch_size) { ParticipantOutcomes::BatchSendLatestOutcomesJob::DEFAULT_BATCH_SIZE }
  let(:default_delay) { ParticipantOutcomes::BatchSendLatestOutcomesJob::DEFAULT_REQUEUE_DELAY }

  context "when a batch size is supplied as an argument" do
    it "enqueues the job with the specified batch size" do
      expect { task.execute(to_task_arguments(500.to_s)) }.to have_enqueued_job(ParticipantOutcomes::BatchSendLatestOutcomesJob).with(500, default_delay)
    end
  end

  context "when a batch size and delay are supplied as arguments" do
    it "enqueues the job with the specified batch size and delay" do
      expect { task.execute(to_task_arguments(500.to_s, 10.to_s)) }.to have_enqueued_job(ParticipantOutcomes::BatchSendLatestOutcomesJob).with(500, 10.seconds)
    end
  end

  context "when no arguments are supplied" do
    it "enqueues the job with the default batch size" do
      expect { task.execute }.to have_enqueued_job(ParticipantOutcomes::BatchSendLatestOutcomesJob).with(default_batch_size, default_delay)
    end
  end
end
