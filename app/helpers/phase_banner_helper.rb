# frozen_string_literal: true

module PhaseBannerHelper
  def phase_banner_tag_text(env = Rails.env)
    return "Beta" if env == "production"

    env.capitalize
  end

  def phase_banner_tag_colour(env = Rails.env)
    {
      "development" => "red",
      "review" => "purple",
      "staging" => "turquoise",
      "sandbox" => "yellow",
    }.fetch(env, nil)
  end

  def maintenance_banner_dismissed?
    dismissed_until = cookies[:dismiss_maintenance_banner_until]
    return if dismissed_until.blank?

    Time.zone.parse(dismissed_until) <= 1.week.from_now
  rescue StandardError => e
    Rails.logger.error "Error parsing maintenance banner dismissal cookie: #{e.message}"
    Sentry.capture_exception(e)
    false
  end
end
