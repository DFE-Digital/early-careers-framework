# frozen_string_literal: true

module Banners
  class MaintenanceComponent < ViewComponent::Base
    HOUR_FORMAT = "%-l%P"
    DAY_FORMAT = "%-d %B"
    MAINTENANCE_WINDOW = Time.zone.local(2024, 11, 27, 19)..Time.zone.local(2024, 11, 27, 22)

    def render?
      FeatureFlag.active?(:maintenance_banner) && maintenance_window_ends_in_future?
    end

  private

    def title_text
      "Important"
    end

    def text
      maintenance_window_spans_days = maintenance_window_start_at.to_date != maintenance_window_end_at.to_date
      maintenance_window_spans_days ? multi_day_window_text : single_day_window_text
    end

    def single_day_window_text
      "This service will be unavailable from #{from_hour} to #{to_hour} on #{from_day}."
    end

    def multi_day_window_text
      "This service will be unavailable from #{from_hour} on #{from_day} to #{to_hour} on #{to_day}."
    end

    def link_text
      "Dismiss"
    end

    def from_hour
      maintenance_window_start_at.strftime(HOUR_FORMAT)
    end

    def to_hour
      maintenance_window_end_at.strftime(HOUR_FORMAT)
    end

    def from_day
      maintenance_window_start_at.strftime(DAY_FORMAT)
    end

    def to_day
      maintenance_window_end_at.strftime(DAY_FORMAT)
    end

    def link_href
      maintenance_banner_dismiss_path
    end

    def maintenance_window_ends_in_future?
      maintenance_window_end_at >= Time.zone.now
    end

    def maintenance_window_start_at
      MAINTENANCE_WINDOW.first
    end

    def maintenance_window_end_at
      MAINTENANCE_WINDOW.last
    end
  end
end
