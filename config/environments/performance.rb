# frozen_string_literal: true

require Rails.root.join("config/environments/production")

Rails.application.configure do
  # Settings specified here will take precedence over those in config/environments/production.rb.

  # Used to handle HTTP_X_WITH_SERVER_DATE header for server side datetime overwrite
  config.middleware.use TimeTraveler

  config.require_master_key = false

  config.public_file_server.enabled = true
  config.force_ssl = false
  config.action_mailer.perform_deliveries = false
  config.active_support.deprecation = :log
  config.log_level = :debug

  logger = ActiveSupport::Logger.new("./log/web.log")
  logger.formatter = config.log_formatter
  config.logger = ActiveSupport::TaggedLogging.new(logger)

  config.active_record.logger = ActiveSupport::Logger.new("./log/sql.log")
end
