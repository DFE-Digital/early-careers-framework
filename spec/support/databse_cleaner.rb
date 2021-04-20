# frozen_string_literal: true

RSpec.configure do |rspec|
  rspec.before(:suite) { DatabaseCleaner.clean_with :truncation }
end
