# frozen_string_literal: true

require "net/http"

class SidekiqSlackNotificationJob
  include Sidekiq::Worker

  queue_as :slack_alerts

  def perform(message)
    post_to_slack(message)
  end

private

  def slack_alerts_webhook_urls
    Rails.configuration.slack_alerts_webhook_urls&.split(",")
  end

  def post_to_slack(message)
    slack_message = "[#{Rails.env.upcase}] #{message}"

    payload = {
      username: "LPDOB Team",
      text: slack_message,
      mrkdwn: true,
    }

    slack_alerts_webhook_urls.map do |slack_alerts_webhook_url|
      uri = URI(slack_alerts_webhook_url)
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 30) do |http|
        http.request(request, payload.to_json)
      end

      raise(SlackMessageError, "Slack error: #{response.body}") unless response.code == "200"
    end
  end
end

class SlackMessageError < StandardError; end
