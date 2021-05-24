# frozen_string_literal: true

class FeatureFlag
  # Long-lived settings that are often environment-specific
  PERMANENT_SETTINGS = %i[
  ].freeze

  # Short-lived feature flags
  TEMPORARY_FEATURE_FLAGS = %i[
    add_participants
  ].freeze

  FEATURES = (PERMANENT_SETTINGS + TEMPORARY_FEATURE_FLAGS).freeze

  def self.activate(feature_name)
    raise unless feature_name.in?(FEATURES)

    ENV["FEATURES_#{feature_name}"] = "active"
  end

  def self.deactivate(feature_name)
    raise unless feature_name.in?(FEATURES)

    ENV["FEATURES_#{feature_name}"] = "inactive"
  end

  def self.active?(feature_name)
    raise unless feature_name.in?(FEATURES)

    ENV["FEATURES_#{feature_name}"] == "active"
  end

  def self.inactive?(feature_name)
    !active?(feature_name)
  end

  def self.set_temporary_flags(features = {})
    originally_active_status = features.map { |name, _| [name, FeatureFlag.active?(name)] }.to_h
    features.each do |name, value|
      FeatureFlag.activate(name) if value == "active"
      FeatureFlag.deactivate(name) if value == "inactive"
    end
    return_value = yield
    originally_active_status.each do |name, originally_active|
      originally_active ? FeatureFlag.activate(name) : FeatureFlag.deactivate(name)
    end
    return_value
  end
end
