# frozen_string_literal: true

require "rake"
require "backfill_mentor_user_id"

namespace :backfill do
  desc "Backfill the mentor_user_id foreign key on ParticipantDeclaration"
  task :mentor_user_id, [:dry_run] => :environment do |_task, args|
    dry_run = ActiveModel::Type::Boolean.new.cast(args[:dry_run] || true)
    BackfillMentorUserId.new(dry_run:).run
  end
end
