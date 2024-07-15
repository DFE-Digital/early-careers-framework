# frozen_string_literal: true

require Rails.root.join("config/environments/production")

Rails.application.configure do
  # Used to handle HTTP_X_WITH_SERVER_DATE header for server side datetime overwrite
  config.middleware.use TimeTraveler

  config.log_level = :warn
  config.ssl_options = { redirect: { exclude: ->(request) { request.path.include?("/check") } } }

  # Enable/disable aspects of the separation environment
  config.npq_separation = {
    disable_npq_endpoints: true,
  }
end
