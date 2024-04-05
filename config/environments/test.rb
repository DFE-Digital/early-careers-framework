# frozen_string_literal: true

require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Turn false under Spring and add config.action_view.cache_template_loading = true.
  config.cache_classes = true

  config.middleware.use TimeTraveler

  # Eager loading loads your whole application. When running a single test locally,
  # this probably isn't necessary. It's a good idea to do in a continuous integration
  # system, or in some way before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}",
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true
  config.active_job.queue_adapter = :test
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = :none

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.record_emails = false
  config.action_mailer.default_options = {
    from: "mail@example.com",
  }
  config.domain = "www.example.com"

  config.support_email = "ecf-support@example.com"

  config.gias_api_schema = "https://www.example-gias.com"
  config.gias_extract_id = 1234
  config.gias_api_user = "gias-user"
  config.gias_api_password = "gias-password"

  config.zendesk_url = "https://www.example.com"
  config.zendesk_username = "zendesk-username"
  config.zendesk_token = "zendesk-token"

  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  if config.respond_to?(:web_console)
    config.web_console.development_only = false
  end

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

  config.dqt_access_url = "https://dqtaccess.example.com/oauth2/v2.0/token"
  config.dqt_access_scope = "https:///dqtaccess.example.com/some-scope"
  config.dqt_access_client_id = "dqt-access-guid"
  config.dqt_access_client_secret = "dqt-access-secret"
  config.dqt_api_url = "https://dtqapi.example.com/dqt-crm"
  config.dqt_api_key = "some-apikey-guid"
  config.qualified_teachers_api_url = "https://qualified-teachers-api.example.com"
  config.qualified_teachers_api_key = "some-apikey-guid"
  config.slack_alerts_webhook_urls = "https://example.com/slack-webhook,https://example.com/slack-webhook"
end
