# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine" Temporarily remove
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

require "govuk/components"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GovukRailsBoilerplate
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.autoloader = :classic

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    Dir.glob(Rails.root + "app/decorators/**/*_decorator*.rb").each do |c|
      require_dependency(c)
    end

    Dir.glob(Rails.root + "app/serializers/**/*_serializer*.rb").each do |c|
      require_dependency(c)
    end

    config.exceptions_app = routes
    config.action_dispatch.rescue_responses["Pundit::NotAuthorizedError"] = :forbidden

    config.middleware.use Rack::Deflater
  end
end
