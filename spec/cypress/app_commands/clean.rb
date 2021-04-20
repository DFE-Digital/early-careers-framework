# frozen_string_literal: true

# cleaning the database using database_cleaner
DatabaseCleaner.clean_with :truncation

FactoryBot.create :privacy_policy, major_version: 0, minor_version: 1

Rails.logger.info "APPCLEANED" # used by log_fail.rb
