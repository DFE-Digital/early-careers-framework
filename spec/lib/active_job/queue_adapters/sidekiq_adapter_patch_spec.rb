# frozen_string_literal: true

require "rails_helper"
require Rails.root.join "lib/active_job/queue_adapters/sidekiq_adapter_patch"

class TestJob; end

RSpec.describe ActiveJob::QueueAdapters::SidekiqAdapter do
  describe ".enqueued_jobs" do
    let(:job) do
      double(args: [{
        job_class: "TestJob",
        arguments: [{ test_key: "test_val" }.stringify_keys],
      }.stringify_keys])
    end

    before do
      queue = double(name: "test_queue")
      allow(queue).to receive(:map).and_yield(job)
      allow(Sidekiq::Queue).to receive(:all).and_return([queue])
    end

    subject(:result) { described_class.new.enqueued_jobs }

    it do
      is_expected.to eq([{
        job: TestJob,
        args: { "test_key" => "test_val" },
        queue: "test_queue",
      }])
    end
  end
end
