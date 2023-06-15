# frozen_string_literal: true

# cleaning the database using database_cleaner
DatabaseCleaner.clean_with :transaction

Rails.logger.info "APPCLEANED" # used by log_fail.rb
