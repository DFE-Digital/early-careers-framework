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
    cookie_value = cookies[:dismiss_maintenance_banner_until]
    return unless cookie_value

    dismissed_until = Time.zone.parse(cookie_value)
    return unless dismissed_until

    dismissed_until > Time.zone.now
  end
end
