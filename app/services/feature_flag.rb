# frozen_string_literal: true

class FeatureFlag
  attr_accessor :name, :description, :owner

  def initialize(name:)
    self.name = name
  end

  def feature
    Feature.find_or_initialize_by(name: name)
  end

  # Long-lived settings that are often environment-specific
  PERMANENT_SETTINGS = %i[
  ].freeze

  # Short-lived feature flags
  TEMPORARY_FEATURE_FLAGS = %i[
    add_participants
    add_participants
  ].freeze

  FEATURES = (PERMANENT_SETTINGS + TEMPORARY_FEATURE_FLAGS).index_with { |name|
    FeatureFlag.new(name: name)
  }.with_indifferent_access.freeze

  def self.activate(feature_name)
    raise unless feature_name.in?(FEATURES)

    sync_with_database(feature_name, true)
  end

  def self.deactivate(feature_name)
    raise unless feature_name.in?(FEATURES)

    sync_with_database(feature_name, false)
  end

  def self.active?(feature_name)
    raise unless feature_name.in?(FEATURES)

    FEATURES[feature_name].feature.active?
  end

  def self.sync_with_database(feature_name, active)
    feature = Feature.find_or_initialize_by(name: feature_name)
    feature.active = active
    feature.save!
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
