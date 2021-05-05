# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").chomp

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.1.3", ">= 6.1.3.1"

# User management and rbac
gem "devise", ">= 4.7.3"
gem "paper_trail"
gem "pundit"

# Pagination
gem "kaminari", ">= 1.2.0"

# Adds health check functionality
gem "health_check", github: "/ianheggie/health_check", ref: "0b799ead604f900ed50685e9b2d469cd2befba5b"

# Cleaner logs, one line per request
gem "lograge"
gem "logstash-event"

# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"

# Use UUIDs as db primary key by default
gem "ar-uuid", "~> 0.2.1"

# Use Puma as the app server
gem "puma", "~> 5.0"

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", ">= 5.2.1"

# Soft delete
gem "discard", "~> 1.2", ">= 1.2.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Manage multiple processes i.e. web server and webpack
gem "foreman"

# Canonical meta tag
gem "canonical-rails", ">= 0.2.11"

gem "listen", ">= 3.0.5", "< 3.4"
gem "rack-attack", ">=6.5.0"

# GOV.UK Notify
gem "mail-notify", ">= 1.0.3"

# do not rely on host's timezone data, which can be inconsistent
gem "tzinfo-data"

# serialization gem that offers more features than active model serializer
gem "blueprinter"

gem "govuk-components", ">= 1.1.5"
gem "govuk_design_system_formbuilder", "~> 2.3.0b1"
gem "view_component", require: "view_component/engine"

# Fetching from APIs
gem "httpclient", "~> 2.8", ">= 2.8.3"
gem "rubyzip", "~> 2.3", ">= 2.3.0"
gem "savon", "~> 2.12", ">= 2.12.1"

# Database based asynchronous priority queue system
gem "daemons"
gem "delayed_cron_job"
gem "delayed_job_active_record"

# OpenApi Swagger
gem "open_api-rswag-api"
gem "open_api-rswag-ui"

platform :mswin, :mingw, :x64_mingw do
  gem "wdm", ">= 0.1.0"
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]

  # GOV.UK interpretation of rubocop for linting Ruby
  gem "rubocop-govuk", ">= 3.17.2"
  gem "scss_lint-govuk"

  # Debugging
  gem "pry-byebug"

  # Testing framework
  gem "rspec-rails", "~> 4.0.1"

  gem "cypress-on-rails", "~> 1.0"
  gem "database_cleaner-active_record"

  gem "dotenv-rails", ">= 2.7.6"

  gem "factory_bot_rails", ">= 6.1.0"

  # Swagger generator
  gem "multi_json"
  gem "open_api-rswag-specs"
  gem "rswag"

  gem "merge_db_schema"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 4.1.0"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  gem "faker"
  gem "jsonapi-rspec"
  gem "pundit-matchers", "~> 1.6.0"
  gem "rails-controller-testing", ">= 1.0.5"
  gem "shoulda-matchers", "~> 4.4"
  gem "simplecov"
  gem "webdrivers", "~> 4.4", ">= 4.4.1"
  gem "webmock"
end
