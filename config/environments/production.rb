# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  config.middleware.use ApiRequestMiddleware

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  config.require_master_key = true unless ENV["IGNORE_SECRETS_FOR_BUILD"]

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  config.cache_store = :redis_cache_store,
                       {
                         url: ENV["REDIS_CACHE_URL"],
                           connect_timeout: 30, # Defaults to 20 seconds
                           reconnect_attempts: 1, # Defaults to 0
                           error_handler: lambda { |method:, returning:, exception:|
                                            # We get a few timeout errors/day from Redis; it may be that the cache is
                                            # under heavy load, but we don't want to be alerted about it.
                                            if exception.instance_of?(Redis::TimeoutError)
                                              Rails.logger.warn("Redis timeout error #{exception}")
                                            else
                                              Sentry.capture_exception(exception, tags: { method:, returning: })
                                            end
                                          },
                       }

  # Use a real queuing backend for Active Job (and separate queues per environment).
  config.active_job.queue_adapter = :sidekiq
  # config.active_job.queue_name_prefix = "early_career_framework_production"
  config.domain = ENV["DOMAIN"]

  config.support_email = "continuing-professional-development@digital.education.gov.uk"

  config.gias_api_schema = ENV["GIAS_API_SCHEMA"]
  config.gias_extract_id = ENV["GIAS_EXTRACT_ID"]
  config.gias_api_user = ENV["GIAS_API_USER"]
  config.gias_api_password = Rails.application.credentials.GIAS_API_PASSWORD

  config.zendesk_url = ENV.fetch("ZENDESK_URL", "https://becomingateacher.zendesk.com/api/v2")
  config.zendesk_username = ENV["ZENDESK_USERNAME"]
  config.zendesk_token = ENV["ZENDESK_TOKEN"]

  config.dqt_api_url = Rails.application.credentials.DQT_API_URL
  config.dqt_api_key = Rails.application.credentials.DQT_API_KEY

  config.slack_alerts_webhook_urls = Rails.application.credentials.SLACK_ALERTS_WEBHOOK_URLS

  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :notify
  unless ENV["IGNORE_SECRETS_FOR_BUILD"]
    config.action_mailer.notify_settings = {
      api_key: Rails.application.credentials.GOVUK_NOTIFY_API_KEY,
    }
  end
  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Log disallowed deprecations.
  config.active_support.disallowed_deprecation = :log

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  # Logging
  config.log_level = (Sidekiq.server?) ? :warn : :info

  # Use Semantic_Logger for cleaner logging
  # # RAILS_LOG_TO_STDOUT is set via https://github.com/DFE-Digital/terraform-modules
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    $stdout.sync = true
    config.semantic_logger.application = "" # No need to send the application name as logstash reads it from Cloud Foundry log tags
    config.rails_semantic_logger.format = :json
    config.rails_semantic_logger.add_file_appender = false
    config.rails_semantic_logger.filter = proc do |log|
      !(log.name == "DfE::Analytics::SendEvents" || log.message&.include?("DfE::Analytics::SendEvents"))
    end
    config.active_record.logger = nil # Don't log SQL in production
    config.semantic_logger.backtrace_level = :error
    config.semantic_logger.add_appender(io: $stdout,
                                        level: config.log_level,
                                        formatter: config.rails_semantic_logger.format,
                                        filter: config.rails_semantic_logger.filter)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Inserts middleware to perform automatic connection switching.
  # The `database_selector` hash is used to pass options to the DatabaseSelector
  # middleware. The `delay` is used to determine how long to wait after a write
  # to send a subsequent read to the primary.
  #
  # The `database_resolver` class is used by the middleware to determine which
  # database is appropriate to use based on the time delay.
  #
  # The `database_resolver_context` class is used by the middleware to set
  # timestamps for the last write to the primary. The resolver uses the context
  # class timestamps to determine how long to wait before reading from the
  # replica.
  #
  # By default Rails will store a last write timestamp in the session. The
  # DatabaseSelector middleware is designed as such you can define your own
  # strategy for connection switching and pass that into the middleware through
  # these configuration options.
  # config.active_record.database_selector = { delay: 2.seconds }
  # config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  # config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session

  # From https://github.com/paper-trail-gem/paper_trail/wiki/Setting-whodunnit-in-the-rails-console
  console do
    PaperTrail.request.whodunnit = lambda {
      @paper_trail_whodunnit ||= begin
        email = nil
        until email.present?
          # rubocop:disable Rails/Output
          puts "Enter your email address for PaperTrail"
          # rubocop:enable Rails/Output
          email = gets.chomp
        end
        email
      end
    }
  end

  config.ssl_options = { redirect: { exclude: ->(request) { request.path.include?("/check") } } }
end
