# frozen_string_literal: true

PaperTrail.enabled = false

if ENV["LEGACY_SEEDS"] == "true"
  seed_path = %w[db legacy_seeds]
  load Rails.root.join(*seed_path, "initial_seed.rb").to_s
  load Rails.root.join(*seed_path, "schedules.rb").to_s

  if %w[development deployed_development test sandbox review].include?(Rails.env)
    %w[test_data dummy_structures appropriate_bodies].each do |seed|
      load Rails.root.join(*seed_path, "#{seed}.rb").to_s
    end
  end

  if Rails.env.development? || Rails.env.deployed_development? || Rails.env.review?
    FeatureFlag::PERMANENT_SETTINGS.each do |feature|
      FeatureFlag.activate(feature)
    end
    FeatureFlag::TEMPORARY_FEATURE_FLAGS.each do |feature|
      FeatureFlag.activate(feature)
    end
  end
else
  load(Rails.root.join(*%w[db new_seeds run.rb]).to_s)
end

PaperTrail.enabled = true
