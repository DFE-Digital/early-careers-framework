# frozen_string_literal: true

Dir[Rails.root.join("db/seeds/initial_seed.rb")].each { |seed| load seed }

if Rails.env.development? || Rails.env.deployed_development?
  Dir[Rails.root.join("db/seeds/dummy_structures.rb")].each { |seed| load seed }
end
