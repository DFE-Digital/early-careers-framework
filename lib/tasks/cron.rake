# frozen_string_literal: true

namespace :cron do
  desc "Updates DelayedJob cron-scheduled tasks"
  task schedule: :environment do
    SessionTrimJob.schedule
    SchoolDataImporterJob.schedule
  end
end
