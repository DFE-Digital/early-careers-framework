# frozen_string_literal: true

namespace :deduping do
  desc "Archive email of all users that are eligible for deduping (no participant identity associated)"
  task dedup_users: :environment do
    DeduplicationService.call
  end

  desc "Delete the dup completed induction records created by the set participant completion date bug"
  task :dedup_completed_induction_records, [:no_of_participants] => :environment do |_task, args|
    DeleteCompletedInductionRecordsJob.perform_later(no_of_participants: args.no_of_participants&.to_i)
  end
end
