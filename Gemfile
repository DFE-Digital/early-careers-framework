# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").chomp

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.1.0"

gem "devise", ">= 4.7.3"
gem "kaminari", ">= 1.2.0"

# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"

# Use Puma as the app server
gem "puma", "~> 5.0"

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", ">= 5.2.1"

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Manage multiple processes i.e. web server and webpack
gem "foreman"

# Canonical meta tag
gem "canonical-rails", ">= 0.2.10"

gem "listen", ">= 3.0.5", "< 3.4"

# GOV.UK Notify
gem "mail-notify", ">= 1.0.3"

# do not rely on host's timezone data, which can be inconsistent
gem "tzinfo-data"

gem "govuk-components", ">= 1.0.0"
gem "govuk_design_system_formbuilder", "~> 2.1", ">= 2.1.5"
gem "govuk_publishing_components", ">= 23.11.0"
gem "sass-rails", ">= 6.0.0"

platform :mswin, :mingw, :x64_mingw do
  gem "wdm", ">= 0.1.0"
end

gem "govspeak", git: "https://github.com/DFE-Digital/ecf-govspeak.git", ref: "5258996"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]

  # GOV.UK interpretation of rubocop for linting Ruby
  gem "rubocop-govuk"
  gem "scss_lint-govuk"

  # Debugging
  gem "pry-byebug"

  # Testing framework
  gem "rspec-rails", "~> 4.0.1"
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", "~> 3.34", ">= 3.34.0"

  gem "dotenv-rails", ">= 2.7.6"

  gem "factory_bot_rails", ">= 6.1.0"
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
  gem "rails-controller-testing", ">= 1.0.5"
  gem "shoulda-matchers", "~> 4.4"
  gem "simplecov"
  gem "webdrivers", "~> 4.4", ">= 4.4.1"
end
