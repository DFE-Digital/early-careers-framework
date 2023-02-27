# frozen_string_literal: true

namespace :participant_outcomes do
  desc "Send participant outcomes to the qualified teachers API"
  task :send_to_qualified_teachers_api, %i[batch_size delay] => :environment do |_task, args|
    job_klass = ParticipantOutcomes::BatchSendLatestOutcomesJob
    batch_size = args[:batch_size]&.to_i || job_klass::DEFAULT_BATCH_SIZE
    delay = args[:delay]&.to_i || job_klass::DEFAULT_REQUEUE_DELAY

    puts "Enqueuing #{job_klass} with batch size #{batch_size} and delay #{delay}s"

    job_klass.perform_later(batch_size, ActiveSupport::Duration.build(delay))
  end
end
