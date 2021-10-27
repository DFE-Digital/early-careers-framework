# frozen_string_literal: true

class SchoolAnalyticsJob < ApplicationJob
  def perform
    Rails.logger.info "Updating school analytics..."
    Analytics::ECFSchoolService.update_school_analytics
  end
end
