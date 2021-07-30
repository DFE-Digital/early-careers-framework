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
    participant_data_api
    induction_tutor_manage_participants
    admin_participants
    admin_delete_participants
    participant_validation
    year_2020_data_entry
    admin_change_programme
    admin_challenge_partnership
  ].freeze

  FEATURES = (PERMANENT_SETTINGS + TEMPORARY_FEATURE_FLAGS).index_with { |name|
    FeatureFlag.new(name: name)
  }.with_indifferent_access.freeze

  def self.activate(feature_name, **opts)
    raise unless feature_name.in?(FEATURES)

    if opts.key?(:for).present?
      sync_with_database_with_object(feature_name, opts[:for], true)
    else
      sync_with_database(feature_name, true)
    end
  end

  def self.deactivate(feature_name, **opts)
    raise "Unknown feature: #{feature_name}" unless feature_name.in?(FEATURES)

    if opts.key?(:for).present?
      sync_with_database_with_object(feature_name, opts[:for], false)
    else
      sync_with_database(feature_name, false)
    end
  end

  def self.active?(feature_name, **opts)
    raise unless feature_name.in?(FEATURES)

    feature = FEATURES[feature_name].feature
    feature.active? || (opts.key?(:for) && feature.selected_objects.exists?(object: opts[:for]))
  end

  def self.sync_with_database(feature_name, active)
    feature = Feature.find_or_initialize_by(name: feature_name)
    feature.active = active
    feature.save!
  end

  def self.sync_with_database_with_object(feature_name, object, active)
    ActiveRecord::Base.transaction do
      feature = Feature.find_or_create_by!(name: feature_name)
      if active
        feature.selected_objects.find_or_create_by!(object: object)
      else
        scope = feature.selected_objects
        scope = scope.where(object: object) unless object == :all
        scope.destroy_all
      end
    end
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
