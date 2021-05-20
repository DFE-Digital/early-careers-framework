# frozen_string_literal: true

Dir[Rails.root.join("db/seeds/initial_seed.rb")].each { |seed| load seed }

if Rails.env.development? || Rails.env.deployed_development? || Rails.env.test?
  Dir[Rails.root.join("db/seeds/test_data.rb")].each { |seed| load seed }
  Dir[Rails.root.join("db/seeds/dummy_structures.rb")].each { |seed| load seed }
end

if Rails.env.sandbox?
  Dir[Rails.root.join("db/seeds/sandbox_data.rb")].each { |seed| load seed }
end
