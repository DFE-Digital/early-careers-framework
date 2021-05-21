# frozen_string_literal: true

Dir[Rails.root.join("db/seeds/initial_seed.rb")].each { |seed| load seed }

if %w[development deployed_development test sandbox].include?(Rails.env)
  Dir[Rails.root.join("db/seeds/test_data.rb")].each { |seed| load seed }
  Dir[Rails.root.join("db/seeds/dummy_structures.rb")].each { |seed| load seed }
  Dir[Rails.root.join("db/seeds/sandbox_data.rb")].each { |seed| load seed }
end
