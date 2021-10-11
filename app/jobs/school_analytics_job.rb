# frozen_string_literal: true

class SchoolAnalyticsJob < CronJob
  self.cron_expression = "10 * * * *"

  queue_as :school_analytics

  def perform
    Rails.logger.info "Updating school analytics..."
    Analytics::ECFSchoolService.update_school_analytics
  end
end
