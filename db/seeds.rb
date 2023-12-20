# frozen_string_literal: true

PaperTrail.enabled = false

if ENV["LEGACY_SEEDS"] == "true"
  seed_path = %w[db legacy_seeds]
  load Rails.root.join(*seed_path, "initial_seed.rb").to_s
  load Rails.root.join(*seed_path, "schedules.rb").to_s

  if Rails.env.in?(%w[development test sandbox staging migration review])
    %w[test_data dummy_structures appropriate_bodies].each do |seed|
      load Rails.root.join(*seed_path, "#{seed}.rb").to_s
    end
  end

  if Rails.env.in?(%w[development staging review])
    FeatureFlag::PERMANENT_SETTINGS.each do |feature|
      FeatureFlag.activate(feature)
    end
    FeatureFlag::TEMPORARY_FEATURE_FLAGS.each do |feature|
      FeatureFlag.activate(feature)
    end
  end
elsif Rails.env.performance?
  load(Rails.root.join(*%w[db new_seeds performance.rb]).to_s)
else
  load(Rails.root.join(*%w[db new_seeds run.rb]).to_s)
end

PaperTrail.enabled = true
