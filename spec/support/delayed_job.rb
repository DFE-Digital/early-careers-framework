# frozen_string_literal: true

class DelayedJobTestAdapter < ActiveJob::QueueAdapters::DelayedJobAdapter
  def enqueued_jobs
    Delayed::Job.all.to_a
  end

  def performed_jobs
    []
  end
end

class TestCronJob < CronJob
  self.cron_expression = "* * * * *"

  def perform; end
end

module DelayedJobMatchers
  extend RSpec::Matchers::DSL

  define :delay_execution_of do |method_name|
    match do |actual|
      handler = Delayed::Job.new(payload_object: Delayed::PerformableMethod.new(actual, method_name, [])).handler
      jobs = Delayed::Job.where("handler LIKE ?", handler.lines.first(3).join + "%")

      return jobs.any? unless @arguments

      jobs.any? do |job|
        @arguments.args_match?(*job.payload_object.args)
      end
    end

    chain :with do |*args|
      @arguments = RSpec::Mocks::ArgumentListMatcher.new(*args)
    end
  end

  RSpec.configure do |rspec|
    rspec.include self
  end
end
