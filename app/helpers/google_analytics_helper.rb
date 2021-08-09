# frozen_string_literal: true

module GoogleAnalyticsHelper
  def get_gtm_id
    if Rails.env.production?
      "G-PHZ5TT3VPD"
    elsif Rails.env.sandbox?
      "G-3HQPHNKLH6"
    else
      "G-LR5YHTJD65"
    end
  end
end
