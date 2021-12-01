# frozen_string_literal: true

namespace :cron do
  desc "Updates DelayedJob cron-scheduled tasks"
  task schedule: :environment do
    SessionTrimJob.schedule
    ImportGiasDataJob.schedule
    SchoolAnalyticsJob.schedule
    StreamBigQueryParticipantDeclarationsJob.schedule if Rails.env.production?
    CreateNewFakeSandboxDataJob.schedule if Rails.env.sandbox?
  end
end
