# frozen_string_literal: true

Dir[Rails.root.join("db/seeds/initial_seed.rb")].each { |seed| load seed }
Dir[Rails.root.join("db/seeds/dummy_structures.rb")].each { |seed| load seed }
