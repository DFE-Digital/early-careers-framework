# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Used to handle HTTP_X_WITH_SERVER_DATE header for server side datetime overwrite
  config.middleware.use TimeTraveler
  config.middleware.use ApiRequestMiddleware

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  config.active_job.queue_adapter = :sidekiq

  config.domain = ENV["DOMAIN"] || "example.com"

  config.support_email = "continuing-professional-development@digital.education.gov.uk"

  config.gias_api_schema = ENV["GIAS_API_SCHEMA"]
  config.gias_extract_id = ENV["GIAS_EXTRACT_ID"]
  config.gias_api_user = ENV["GIAS_API_USER"]
  config.gias_api_password = ENV["GIAS_API_PASSWORD"]

  config.zendesk_url = ENV.fetch("ZENDESK_URL", "https://becomingateacher.zendesk.com/api/v2")
  config.zendesk_username = ENV["ZENDESK_USERNAME"]
  config.zendesk_token = ENV["ZENDESK_TOKEN"]

  config.dqt_client_api_key = ENV["DQT_CLIENT_API_KEY"]
  config.dqt_client_host = ENV["DQT_CLIENT_HOST"]
  config.dqt_client_params = ENV["DQT_CLIENT_PARAMS"]

  config.dqt_access_url = ENV["DQT_ACCESS_URL"]
  config.dqt_access_scope = ENV["DQT_ACCESS_SCOPE"]
  config.dqt_access_client_id = ENV["DQT_ACCESS_CLIENT_ID"]
  config.dqt_access_client_secret = ENV["DQT_ACCESS_CLIENT_SECRET"]

  config.dqt_api_url = ENV["DQT_API_URL"]
  config.dqt_api_key = ENV["DQT_API_KEY"]

  config.qualified_teachers_api_url = ENV["QUALIFIED_TEACHERS_API_URL"]
  config.qualified_teachers_api_key = ENV["QUALIFIED_TEACHERS_API_KEY"]

  config.slack_alerts_webhook_urls = ENV["SLACK_ALERTS_WEBHOOK_URLS"]

  config.npq_registration_api_url = ENV["NPQ_REGISTRATION_API_URL"]

  # Don't care if the mailer can't send.
  # config.action_mailer.raise_delivery_errors = true

  config.action_mailer.notify_settings = {
    api_key: ENV.fetch("GOVUK_NOTIFY_API_KEY"),
  }
  config.action_mailer.delivery_method = :notify
  config.action_mailer.perform_deliveries = true
  config.action_mailer.perform_caching = false
  config.action_mailer.logger = Logger.new("log/mail.log", formatter: proc { |_, _, _, msg|
    if msg =~ /quoted-printable/
      message = Mail::Message.new(msg)
      "\nTo: #{message.to}\n\n#{message.decoded}\n\n"
    else
      "\n#{msg}"
    end
  })

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}",
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true
end
