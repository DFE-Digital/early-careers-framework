# frozen_string_literal: true

namespace :deduping do
  desc "Archive email of all users that are eligible for deduping (no participant identity associated)"
  task dedup_users: :environment do
    DeduplicationService.dedup_users!
  end
end
