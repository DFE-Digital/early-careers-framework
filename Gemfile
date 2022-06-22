# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(Pathname.new(__dir__).join(".ruby-version")).strip

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.1.6"

# User management and rbac
gem "devise", ">= 4.8.0"
gem "paper_trail"
gem "pretender", ">= 0.4.0"
gem "pundit"

# Error and performance monitoring
gem "sentry-rails", "~> 5.3"
gem "sentry-ruby", "~> 5.3"
gem "sentry-sidekiq"

gem "secure_headers"

# Cleaner logs, one line per request
gem "lograge", "~> 0.12.0"
gem "logstash-event"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.3"

# Use UUIDs as db primary key by default
gem "ar-uuid", "~> 0.2.2"

# Use Puma as the app server
gem "puma", "~> 5.6"

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "shakapacker", "~> 6.2"

# Soft delete
gem "discard", "~> 1.2", ">= 1.2.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.11", require: false

# Manage multiple processes i.e. web server and webpack
gem "foreman"

# Canonical meta tag
gem "canonical-rails", "~> 0.2.14"

gem "listen", "~> 3.7"
gem "rack-attack", "~> 6.6"

# GOV.UK Notify
gem "mail-notify", "~> 1.0", ">= 1.0.4"

# do not rely on host's timezone data, which can be inconsistent
gem "tzinfo-data"

gem "govuk-components", "~> 3.0", ">= 3.0.3"
gem "govuk_design_system_formbuilder", "~> 2.8"
gem "view_component", require: "view_component/engine"

# Fetching from APIs
gem "httpclient", "~> 2.8", ">= 2.8.3"
gem "rubyzip", "~> 2.3", ">= 2.3.0"
gem "savon", "~> 2.12", ">= 2.12.1"

# Strong migration checker for database migrations
gem "strong_migrations", "~> 1.2"

# Acts as State Machine for participant and declaration states
gem "aasm"

# Pagination
gem "pagy", "~> 5.10", ">= 5.10.1"

# Json Schema for api validation
gem "json-schema", ">= 2.8.1"

gem "jsonapi-serializer"

# OpenApi Swagger
gem "openapi3_parser", "~> 0.9.2"

gem "ransack"

# Payment breakdown
gem "terminal-table"

gem "friendly_id", "~> 5.4", ">= 5.4.2"

platform :mswin, :mingw, :x64_mingw do
  gem "wdm", "~> 0.1"
end

# S3 adapter for active storage
gem "aws-sdk-s3", require: false

gem "activerecord-session_store", "~> 2.0"

gem "google-cloud-bigquery"

gem "sidekiq"
gem "sidekiq-cron"

gem "net-imap", require: false
gem "net-pop", require: false
gem "net-smtp", require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]

  # GOV.UK interpretation of rubocop for linting Ruby
  gem "rubocop-govuk", ">= 4.5"

  gem "scss_lint-govuk"

  # Debugging
  gem "pry-byebug"

  # Testing framework
  gem "rspec-rails", "~> 5.1"

  gem "cypress-on-rails", "~> 1.12"
  gem "database_cleaner-active_record"

  gem "dotenv-rails", "~> 2.7.6"

  # Swagger generator
  gem "multi_json"
  gem "open_api-rswag-specs", "~> 0.1.0"

  gem "parallel_tests"
end

group :development, :deployed_development, :test, :sandbox do
  gem "factory_bot_rails", "~> 6.2.0"
  gem "faker"
  gem "timecop"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", "~> 4.2.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0"

  # autocompletion backend for development
  gem "solargraph"

  # State machine diagrams - https://github.com/Katee/aasm-diagram
  gem "aasm-diagram"

  # Profiling
  gem "memory_profiler"
  gem "rack-mini-profiler"
  gem "stackprof"
end

group :test do
  gem "axe-core-rspec"
  gem "capybara", "~> 3.37"
  gem "jsonapi-rspec"
  gem "launchy"
  gem "percy-capybara"
  gem "pundit-matchers", "~> 1.7.0"
  gem "rails-controller-testing", "~> 1.0.5"
  gem "rspec-default_http_header", "~> 0.0.6"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 5.1"
  gem "simplecov"
  gem "site_prism", "~> 3.7"
  gem "webdrivers", "~> 5.0"
  gem "webmock", "~> 3.14"
  gem "with_model"
end
