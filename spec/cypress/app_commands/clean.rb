# frozen_string_literal: true

# cleaning the database using database_cleaner
DatabaseCleaner.clean_with :truncation

Rails.logger.info "APPCLEANED" # used by log_fail.rb
