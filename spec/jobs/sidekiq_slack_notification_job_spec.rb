# frozen_string_literal: true

require "rails_helper"

RSpec.describe SidekiqSlackNotificationJob do
  describe "#perform" do
    subject(:job) { described_class.new }

    it "sends a Slack notification to this webhook" do
      slack_request = stub_request(:post, "https://example.com:443/slack-webhook")
                        .with(
                          body: "{\"username\":\"LPDOB Team\",\"text\":\"[TEST] example message\",\"mrkdwn\":true}",
                          headers: {
                            "Accept"=>"*/*",
                          "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
                          "Content-Type"=>"application/json",
                          "Host"=>"example.com",
                          "User-Agent"=>"Ruby",
                          },
                        )
                        .to_return(status: 200, body: "", headers: {})

      job.perform("example message")

      expect(slack_request).to have_been_made.twice
    end

    it "raises an error if Slack responds with an error" do
      stub_request(:post, "https://example.com:443/slack-webhook").to_return(status: 400, headers: {})

      expect { job.perform("example message") }.to raise_error(SlackMessageError)
    end
  end
end
