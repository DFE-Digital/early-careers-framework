# frozen_string_literal: true

module ActiveJob
  module QueueAdapters
    # Adds enqueued_jobs method consistent with the TestAdapter
    #
    class SidekiqAdapter
      def enqueued_jobs
        Sidekiq::Queue.all.map { |queue|
          queue.map do |job|
            {
              job: job.args.first["job_class"].constantize,
              args: job.args.first["arguments"].first,
              queue: queue.name,
            }
          end
        }.flatten
      end
    end
  end
end
