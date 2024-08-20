# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(Pathname.new(__dir__).join(".ruby-version")).strip

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.1.3"

# User management and rbac
gem "devise", ">= 4.8.0"
gem "paper_trail"
gem "pretender", ">= 0.4.0"
gem "pundit"

# Error and performance monitoring
gem "sentry-rails", "~> 5.18"
gem "sentry-ruby", "~> 5.19"
gem "sentry-sidekiq"

# Support queries
gem "zendesk_api"

gem "secure_headers"

gem "rails_semantic_logger"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5"

# Use UUIDs as db primary key by default
gem "ar-uuid", "~> 0.2.3"

# Use Puma as the app server
gem "puma", "~> 5.6"

# Soft delete
gem "discard", "~> 1.3"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.18", require: false

# Manage multiple processes i.e. web server and webpack
gem "foreman"

# Canonical meta tag
gem "canonical-rails", "~> 0.2.15"

gem "listen", "~> 3.9"
gem "rack-attack", "~> 6.7"

# GOV.UK Notify
gem "mail-notify", "~> 1.2"

# do not rely on host's timezone data, which can be inconsistent
gem "tzinfo-data"

gem "govuk-components", "~> 5.4.1"
gem "govuk_design_system_formbuilder", "~> 5.5.0"

# Fetching from APIs
gem "httpclient", "~> 2.8", ">= 2.8.3"
gem "rubyzip", "~> 2.3", ">= 2.3.0"
gem "savon", "~> 2.15"

# Strong migration checker for database migrations
gem "strong_migrations", "~> 1.8"

# Pagination
gem "pagy", "~> 6"

# Json Schema for api validation
gem "json-schema", ">= 2.8.1"

gem "jsonapi-serializer"

# OpenApi Swagger
gem "openapi3_parser", "~> 0.9.2"

gem "ransack"

gem "friendly_id", "~> 5.5"

platform :mswin, :mingw, :x64_mingw do
  gem "wdm", "~> 0.1"
end

gem "activerecord-session_store", "~> 2.1"

gem "active_record_extended"

gem "google-cloud-bigquery"

gem "sidekiq"
gem "sidekiq-cron"

gem "net-imap", require: false
gem "net-pop", require: false
gem "net-smtp", require: false

gem "json-diff", "~> 0.4.1", require: false

gem "cssbundling-rails", "~> 1.4"
gem "jsbundling-rails"
gem "sprockets", "~> 4.2.1"
gem "sprockets-rails", require: "sprockets/railtie"

# Code Highlighter
gem "rouge"

gem "auto_strip_attributes", "~> 2.6"

gem "dfe-analytics", github: "DFE-Digital/dfe-analytics", tag: "v1.14.0"
gem "dfe-wizard", github: "DFE-Digital/dfe-wizard"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]

  # GOV.UK interpretation of rubocop for linting Ruby
  gem "rubocop-govuk", ">= 4.8"

  gem "scss_lint-govuk"

  # Debugging
  gem "pry-byebug"

  # Testing framework
  gem "rspec-rails", "~> 6.1.4"

  gem "database_cleaner-active_record"

  gem "dotenv-rails", "~> 2.8.1"

  # Swagger generator
  gem "multi_json"
  gem "rswag-specs", "~> 2.14"

  gem "parallel_tests"

  # Linting
  gem "erb_lint", ">= 0.1.1", require: false

  # Colourizing output
  gem "amazing_print"
end

group :development, :test, :staging, :sandbox, :review, :performance, :migration, :separation do
  gem "factory_bot_rails", "~> 6.4.3"
  gem "faker"
  gem "timecop"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", "~> 4.2.1"

  # autocompletion backend for development
  gem "solargraph"

  gem "activerecord-explain-analyze"

  # Profiling
  gem "memory_profiler"
  gem "rack-mini-profiler"
  gem "stackprof"

  gem "nokogiri"
end

group :test do
  gem "axe-core-rspec"
  gem "capybara", "~> 3.40"
  gem "jsonapi-rspec"
  gem "launchy"
  gem "pundit-matchers", "~> 1.9.0"
  gem "rails-controller-testing", "~> 1.0.5"
  gem "rspec-default_http_header", "~> 0.0.6"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 5.3"
  gem "simplecov"
  gem "site_prism", "~> 3.7"
  gem "webmock", "~> 3.23"
  gem "with_model"
end

gem "countries", "~> 5.7"
gem "scenic", "~> 1.8"
