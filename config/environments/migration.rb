# frozen_string_literal: true

require Rails.root.join("config/environments/production")

Rails.application.configure do
  config.log_level = :debug
  config.ssl_options = { redirect: { exclude: ->(request) { request.path.include?("/check") } } }

  config.npq_registration_api_url = "https://npq-registration-migration-web.teacherservices.cloud"
end
