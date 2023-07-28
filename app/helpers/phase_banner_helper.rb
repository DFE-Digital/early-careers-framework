# frozen_string_literal: true

module PhaseBannerHelper
  def phase_banner_tag_text(env = Rails.env)
    return "Beta" if env == "production"

    env
  end

  def phase_banner_tag_colour(env = Rails.env)
    {
      "development" => "red",
      "review" => "purple",
      "staging" => "turquoise",
      "sandbox" => "yellow",
    }.fetch(env, nil)
  end
end
