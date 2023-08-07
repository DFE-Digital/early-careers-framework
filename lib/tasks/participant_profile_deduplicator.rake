# frozen_string_literal: true

require "rake"
require "participant_profile_deduplicator"

namespace :participant_profile_deduplicator do
  desc "Perform a dry-run of the deduplication task"
  task :dedup_dry_run, %i[primary_profile_id duplicate_profile_id] => :environment do |_task, args|
    Rails.logger = Logger.new($stdout)
    deduplicator = ParticipantProfileDeduplicator.new(args[:primary_profile_id], args[:duplicate_profile_id], dry_run: true)
    deduplicator.dedup!
  end
end
