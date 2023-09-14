# frozen_string_literal: true

if Rails.env.in?(%w[development review staging])
  Rails.logger.info("activating permanent feature flags")

  FeatureFlag::PERMANENT_SETTINGS.each do |feature|
    FeatureFlag.activate(feature)
  end

  Rails.logger.info("activating temporary feature flags")
  FeatureFlag::TEMPORARY_FEATURE_FLAGS.each do |feature|
    FeatureFlag.activate(feature)
  end
end
