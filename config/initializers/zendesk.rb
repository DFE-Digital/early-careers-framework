# frozen_string_literal: true

require "zendesk_api"

Rails.application.config.zendesk_client = ZendeskAPI::Client.new do |config|
  config.url = Rails.application.config.zendesk_url
  config.username = Rails.application.config.zendesk_username
  config.token = Rails.application.config.zendesk_token
  config.raise_error_when_rate_limited = true
end
