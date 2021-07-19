# frozen_string_literal: true

if Rails.env.development? || Rails.env.deployed_development?
  FeatureFlag::PERMANENT_SETTINGS.each do |feature|
    FeatureFlag.activate(feature)
  end
  FeatureFlag::TEMPORARY_FEATURE_FLAGS.each do |feature|
    FeatureFlag.activate(feature)
  end
end
