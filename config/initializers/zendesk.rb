# frozen_string_literal: true

require "zendesk_api"

Rails.application.config.zendesk_client = ZendeskAPI::Client.new do |config|
  config.url = ENV.fetch("ZENDESK_URL", "https://teachercpdhelp.zendesk.com/api/v2")
  config.username = ENV.fetch("ZENDESK_USERNAME", nil)
  config.token = ENV.fetch("ZENDESK_TOKEN", nil)
  config.raise_error_when_rate_limited = true
end
