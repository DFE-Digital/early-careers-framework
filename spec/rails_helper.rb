# frozen_string_literal: true

require "simplecov"
SimpleCov.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../app/helpers/application_helper"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
require "devise"
require "pundit/rspec"
require "pundit/matchers"
require "support/new_supplier_helper"
require "paper_trail/frameworks/rspec"
require "sidekiq/testing"

# require features_helper after support files have been loaded
require "features_helper"

Capybara.server = :puma, { Silent: true }

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  config.include RSpec::DefaultHttpHeader, type: :request

  config.include JSONAPI::RSpec

  config.before do
    Faker::Number.unique.clear
    enqueued_jobs.clear
  end
  config.include Devise::Test::IntegrationHelpers, type: :request
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = ::Rails.root.join("spec/fixtures").to_path

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.before(:each, type: :request) do
    host! Rails.configuration.domain
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec::Matchers.define_negated_matcher :not_have_enqueued_mail, :have_enqueued_mail
RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include ActiveSupport::Testing::TimeHelpers
  config.include ActiveJob::TestHelper
  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
  config.include Rails.application.routes.url_helpers

  config.before(:each, exceptions_app: true) do
    # Make the app behave how it does in non dev/test environments and use the
    # ErrorsController via config.exceptions_app = routes in config/application.rb
    method = Rails.application.method(:env_config)
    expect(Rails.application).to receive(:env_config).with(no_args) do
      method.call.merge(
        "action_dispatch.show_exceptions" => true,
        "action_dispatch.show_detailed_exceptions" => false,
        "consider_all_requests_local" => false,
      )
    end
  end

  config.around(:each, :with_feature_flags) do |example|
    FeatureFlag.set_temporary_flags(example.metadata.fetch(:with_feature_flags)) do
      example.run
    end
  end

  config.around(:each, :travel_to) do |example|
    travel_to(example.metadata.fetch(:travel_to)) do
      example.run
    end
  end
end
