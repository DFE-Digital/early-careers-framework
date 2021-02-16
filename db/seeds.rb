# frozen_string_literal: true

# store all seeds inside the folder db/seeds

Dir[Rails.root.join("db/seeds/cip_seed.rb")].each { |seed| load seed }

Dir[Rails.root.join("db/seeds/dummy_structures.rb")].each { |seed| load seed }
