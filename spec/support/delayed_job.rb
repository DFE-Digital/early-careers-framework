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

# While rails provides a number of helpers to deal with enqueued jobs and email, those helpers are limited
# in a number of ways making it impossible to test certain scenarios:
#   1. Matchers are not aware of jobs scheduled outside of ActiveJob, e.g. calls like
#     `some_object.delay.some_method(argument)` is not inspectable via `enqueued_jobs`
#   2. ActiveJob is not aware of database transactions and transactional behaviour of DelayedJob,
#      meaning that `enqueued_jobs` will contain jobs that has not been commited in the database.
#
# The matchers defined here relies on the job record being stored in the database, fixing both the issues above
# and hopefully drastically improving our confidence in the unit tests.
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
  # How:
  #   DelayedJob allows any object with `perform` method to be invoked as a background job.
  #   For `some_object.delay.some_method`
  #   DJ creates an instance of PerformableMethod, which stores all `some_object`, `method_name` and `arguments`
  #   and then stores this object in the database record serialized into YAML as `payload_object`.
  #
  #   In order to asnwer the question "was the execution of some_method on some_object enqueued for execution with
  #   given arguments", we need to query enqueued_jobs from the database based on that YAML column, DJ was
  #   not desinged for querability. To do this, we recreate yaml representation of the payload_object.
  #   At the time of writing, I've decided to limit the query by the some_object class and method name, as
  #   it is possible that `some_object` state representation could be time sensitive.
  #
  #   Once the list of potenital jobs matching criteria is returned from the database, we filter them
  #   down manually to ensure given arguments matches expectations
  define :delay_execution_of do |method_name|
    match do |actual|
      jobs = query_jobs(actual, method_name)

      jobs.any? do |job|
        result = true
        result &&= @arguments.args_match?(*job.payload_object.args) if @arguments
        result &&= job.run_at == @at if @at.present?
        result
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
        next object == job.payload_object.object unless object.respond_to?(:matches?)

        object.matches? job.payload_object.object
      end
    end
  end

  # Usage:
  #    expect(active_job).to be_enqueued.with(arguments / argument_matchers)
  #
  # Examples:
  #    MyActiveJob.perform_later("hello")
  #
  #    expect(MyActiveJob).to be_enqueued.with(an_instance_of String) #=> success
  #    expect(MyActiveJob).to be_enqueued                             #=> success
  #    expect(MyActiveJob).to be_enqueued.with("hello")               #=> success
  #    expect(MyActiveJob).to be_enqueued.with("Hello")               #=> failure
  define :be_enqueued do
    match do |job_class|
      job_arguments = find_job_with_arguments(job_class)

      job_arguments.any? do |job, args|
        result = true
        result &&= @arguments.args_match?(*args) if @arguments.present?
        result &&= job.run_at == @at if @at.present?
        result
      end
    end

    chain :with do |*args|
      @arguments = RSpec::Mocks::ArgumentListMatcher.new(*args)
    end

    chain :at do |datetime|
      @at = datetime
    end

    def find_job_with_arguments(job_class)
      Delayed::Job
        .where("handler LIKE '--- !ruby/object:ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper%'")
        .where("handler LIKE ?", "%\n  job_class: #{job_class.name}\n%")
        .index_by(&:itself)
        .transform_values { |dj_job| ActiveJob::Base.deserialize(dj_job.payload_object.job_data) }
        .each_value { |aj_job| aj_job.send(:deserialize_arguments_if_needed) }
        .transform_values(&:arguments)
    end
  end

  # Usage:
  #    expect(Mailer).to delay_email_delivery_of(:some_email).with(arguments / argument_matchers)
  #
  # Examples:
  #    Mailer.email(name: "My name").deliver_later
  #
  #    expect(Mailer).to delay_email_delivery_of(:email).with(hash_including :name) #=> success
  #    expect(Object).to delay_email_delivery_of(:email)                            #=> success
  #    expect(Object).to delay_email_delivery_of(:email).with(name: "My name")      #=> success
  #    expect(Object).to delay_email_delivery_of(:email).with(name: "Hello")        #=> failure
  #
  # How:
  #   `deliver_later` comes from ActiveJob, which wraps the mailer call inside `ActionMailer::MailDeliveryJob`,
  #   which inherits from `ActiveJob::Base`. This job, as all ActiveJob::Base jobs, is then wrapped in
  #   yet another wrapper for Delayed::Job - ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper.
  #
  #   To effectively query and access arguments passed to the mailer we need to unwrap both layers

  define :delay_email_delivery_of do |email_name|
    match do |mailer_class|
      email_arguments = find_email_args(mailer_class, email_name)
      return email_arguments.any? unless @arguments

      email_arguments.any? do |args|
        @arguments.args_match?(*args)
      end
    end

    chain :with do |*args|
      @arguments = RSpec::Mocks::ArgumentListMatcher.new(*args)
    end

    # TODO: Also find email enqueued without ActiveJob, i.e. Mailer.delay.email
    def find_email_args(mailer_class, email_name)
      find_active_job_mails_arguments(mailer_class, email_name)
    end

    # Emails enqueued with ActiveJob's `Mailer.email(...).deliver_later
    def find_active_job_mails_arguments(mailer_class, email_name)
      Delayed::Job
        .where("handler LIKE '--- !ruby/object:ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper%'")
        .where("handler LIKE '%\n  job_class: ActionMailer::MailDeliveryJob%'")
        .where("handler LIKE ?", "%\n  arguments:\n  - #{mailer_class.name}\n  - #{email_name}%")
        .map { |dj_job| ActiveJob::Base.deserialize(dj_job.payload_object.job_data) } # unwrapping DelayedJobAdapter::JobWrapper
        .each { |aj_job| aj_job.send(:deserialize_arguments_if_needed) }
        .map { |aj_job| aj_job.arguments[3][:args] } # MailDeliveryJobs arguments are `[mailer_class, email_name, delivery_method, {args:, params:}]`
    end
  end

  RSpec.configure do |rspec|
    rspec.include self
  end
end
