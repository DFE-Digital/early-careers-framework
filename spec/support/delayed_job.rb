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

  # Usage:
  #    expect(some_object).to delay_execution_of(:some_method).with(arguments / argument_matchers)
  #
  # Examples:
  #    Object.delay.puts("hello")
  #
  #    expect(Object).to delay_execution_of(:puts).with(an_instance_of String) #=> success
  #    expect(Object).to delay_execution_of(:puts)                             #=> success
  #    expect(Object).to delay_execution_of(:puts).with("hello")               #=> success
  #    expect(Object).to delay_execution_of(:puts).with("Hello")               #=> failure
  #
  # Why:
  #
  # While rails provides a number of helpers to deal with enqueued jobs, those helpers are limited
  # in a number of ways making it impossible to test certain scenarios:
  #   1. Matchers are not aware of jobs scheduled outside of ActiveJob, e.g. calls like
  #     `some_object.delay.some_method(argument)` is not inspectable via `enqueued_jobs`
  #   2. ActiveJob is not aware of database transactions and transactional behaviour of DelayedJob,
  #      meaning that `enqueued_jobs` will contain jobs that has not been committed in the database.
  #
  # This matchers relies on the job record being stored in the database, fixing both the issues above
  # drastically improving our confidence in the unit tests.
  #
  # How:
  #
  # This is a bit complex and requires some knowledge about DelayedJob internals. DelayedJob allows
  # any object with `perform` method to be invoked as a background job. For `some_object.delay.some_method`
  # DJ creates an instance of PerformableMethod, which stores all `some_object`, `method_name` and `arguments`
  # and then stores this object in the database record serialized into YAML as `payload_object`.
  #
  # In order to answer the question "was the execution of some_method on some_object enqueued for execution with
  # given arguments", we need to query enqueued_jobs from the database based on that YAML column, DJ was
  # not designed for queriability. To do this, we recreate yaml representation of the payload_object.
  # At the time of writing, I've decided to limit the query by the some_object class and method name, as
  # it is possible that `some_object` state representation could be time sensitive.
  #
  # Once the list of potential jobs matching criteria is returned from the database, we filter them
  # down manually to ensure given arguments matches expectations

  define :delay_execution_of do |method_name|
    match do |actual|
      jobs = query_jobs(actual, method_name)
      return jobs.any? unless @arguments || @at

      jobs.any? do |job|
        @arguments.args_match?(*job.payload_object.args)
        job.run_at == @at if @at.present?
      end
    end

    chain :with do |*args|
      @arguments = RSpec::Mocks::ArgumentListMatcher.new(*args)
    end

    chain :at do |datetime|
      @at = datetime
    end

  private

    def query_jobs(object, method_name)
      scope = Delayed::Job
        .where("handler LIKE '--- !ruby/object:Delayed::PerformableMethod%'")
        .where("handler LIKE ?", "%\nmethod_name: :#{method_name}\n%")

      scope.select do |job|
        return object == job.payload_object.object unless object.respond_to?(:matches?)

        object.matches? job.payload_object.object
      end
    end
  end

  RSpec.configure do |rspec|
    rspec.include self
  end
end
