# frozen_string_literal: true

require_relative "seeds/initial_seed"

if Rails.env.development? || Rails.env.deployed_development?
  require_relative "seeds/test_data"
  require_relative "seeds/dummy_structures"
end
