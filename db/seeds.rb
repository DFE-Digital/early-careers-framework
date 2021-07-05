# frozen_string_literal: true

seed_path = %w[db seeds]

load Rails.root.join(*seed_path, "initial_seed.rb").to_s

if %w[development deployed_development test sandbox].include?(Rails.env)
  %w[test_data dummy_structures].each do |seed|
    load Rails.root.join(*seed_path, "#{seed}.rb").to_s
  end
end
