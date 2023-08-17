# frozen_string_literal: true

require "rails_helper"

RSpec.describe DetectSidekiqMetricsIssuesJob do
  let(:size) { 100 }
  let(:latency) { 100 }
  let(:sidekiq_retries) { instance_double(Sidekiq::RetrySet, size:) }
  let(:sidekiq_queue) { instance_double(Sidekiq::Queue, latency:) }

  before do
    allow(SidekiqSlackNotificationJob).to receive(:perform_async)
    allow(Sidekiq::RetrySet).to receive(:new).and_return(sidekiq_retries)
    allow(Sidekiq::Queue).to receive(:new).and_return(sidekiq_queue)

    described_class.new.perform
  end

  describe "#perform" do
    context "when sidekiq retries queue is high" do
      let(:size) { 300 }

      it "sends an alert to Slack" do
        expect(SidekiqSlackNotificationJob).to have_received(:perform_async).with("Sidekiq pending retries depth is high (300). Suggests high error rate.")
      end
    end

    context "when sidekiq retries queue is low" do
      let(:size) { 20 }

      it "does not send an alert" do
        expect(SidekiqSlackNotificationJob).not_to have_received(:perform_async).with("Sidekiq pending retries depth is high (20). Suggests high error rate.")
      end
    end

    context "when sidekiq latency for selected queues is high" do
      let(:latency) { described_class::SIDEKIQ_LATENCY_THRESHOLD + 0.9 }

      it "sends an alert to Slack" do
        described_class::SIDEKIQ_QUEUE_NAMES.each do |queue_name|
          expect(SidekiqSlackNotificationJob).to have_received(:perform_async).with("Sidekiq queue #{queue_name} latency is high (#{latency}).")
        end
      end
    end

    context "when sidekiq latency for selected queues is low" do
      let(:latency) { described_class::SIDEKIQ_LATENCY_THRESHOLD - 0.2 }

      it "does not send an alert" do
        described_class::SIDEKIQ_QUEUE_NAMES.each do |queue_name|
          expect(SidekiqSlackNotificationJob).not_to have_received(:perform_async).with("Sidekiq queue #{queue_name} latency is high (#{latency}).")
        end
      end
    end
  end
end
