# frozen_string_literal: true

RSpec.describe "rake participant_outcomes:send_to_qualified_teachers_api", type: :task do
  context "when a batch size is supplied as an argument" do
    it "enqueues the job with the specified batch size" do
      expect { task.execute(to_task_arguments(500.to_s)) }.to have_enqueued_job(ParticipantOutcomes::BatchSendLatestOutcomesJob).with(500)
    end
  end

  context "when no arguments are supplied" do
    it "enqueues the job with the default batch size" do
      expect { task.execute }.to have_enqueued_job(ParticipantOutcomes::BatchSendLatestOutcomesJob).with(200)
    end
  end
end
