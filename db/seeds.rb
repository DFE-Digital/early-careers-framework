# frozen_string_literal: true

load Rails.root.join("db/seeds/initial_seed.rb")

if %w[development deployed_development test sandbox].include?(Rails.env)
  %w[test_data dummy_structures sandbox_data].each do |seed|
    load Rails.root.join("db/seeds", "#{seed}.rb")
  end
end
