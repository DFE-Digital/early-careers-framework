# frozen_string_literal: true

module Banners
  class MaintenanceComponent < ViewComponent::Base
    attr_reader :wide_container_view

    # Set the following constants to the appropriate dates and times to enable the upcoming maintenance warning.
    #
    # date - required (for rendering)
    # start_time - optional
    # end_time - optional
    DATE       = Date.new(2023, 9, 14)
    START_TIME = Time.zone.local(2023, 9, 14, 18, 0, 0)
    END_TIME   = Time.zone.local(2023, 9, 14, 21, 0, 0)

    def initialize(wide_container_view: false)
      @wide_container_view = wide_container_view
    end

    def render?
      date.present? && date_is_in_future? && FeatureFlag.active?(:maintenance_banner)
    end

    def unavailable_timeframe_string
      if start_time.present?
        return "from #{formatted_start_time} to #{formatted_end_time} on #{formatted_date}" if end_time.present?

        "from #{formatted_start_time} on #{formatted_date}"
      elsif end_time.present?
        "until #{formatted_end_time} on #{formatted_date}"
      else
        "on #{formatted_date}"
      end
    end

  private

    def start_time
      START_TIME
    end

    def end_time
      END_TIME
    end

    def date
      DATE
    end

    def date_is_in_future?
      date.to_time.beginning_of_day > Time.current.end_of_day
    end

    def formatted_date
      date.strftime("%-e %B %Y")
    end

    def formatted_start_time
      formatted_time(start_time)
    end

    def formatted_end_time
      formatted_time(end_time)
    end

    def formatted_time(time)
      return "midnight" if time.strftime("%H:%M") == "00:00"
      return "midday" if time.strftime("%H:%M") == "12:00"
      return time.strftime("%-l%P") if time.strftime("%M") == "00"

      time.strftime("%-l:%M%P")
    end
  end
end
