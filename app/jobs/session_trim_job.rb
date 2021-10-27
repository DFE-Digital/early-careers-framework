# frozen_string_literal: true

class SessionTrimJob < ApplicationJob
  def perform
    Rails.logger.info "Trimming session store..."

    cutoff_period = ENV.fetch("SESSION_DAYS_TRIM_THRESHOLD", 30).to_i.days.ago

    ActiveRecord::SessionStore::Session
      .where("updated_at < ?", cutoff_period)
      .delete_all
  end
end
