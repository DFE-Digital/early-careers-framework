# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionRestoreErrorRescueMiddleware do
  let(:session_key) { Rails.application.config.session_options[:key] }

  let(:env) do
    {
      "HTTP_COOKIE" => "#{session_key}=session_data; other_cookie=bar",
      "rack.session" => { user_id: 42 },
      "rack.session.options" => { expire_after: 3600 },
    }
  end

  let(:good_app) { ->(env) { [200, env, %w[OK]] } }

  let(:bad_app) do
    lambda do |env|
      if env["rack.session"].present?
        begin
          raise "Test error"
        rescue StandardError
          raise ActionDispatch::Session::SessionRestoreError
        end
      else
        [200, env, %w[OK]]
      end
    end
  end

  context "when no session restore error is raised" do
    it "calls the downstream app and returns its response" do
      middleware = described_class.new(good_app)
      status, headers, body = middleware.call(env)
      expect(status).to eq(200)
      expect(body).to eq(%w[OK])
      # expect(headers).to eq(env)

      req = ActionDispatch::Request.new(headers)
      expect(req.env["rack.session"]).to eq({ user_id: 42 })
      expect(req.env["rack.session.options"]).to eq({ expire_after: 3600 })
      expect(req.cookies["other_cookie"]).to eq("bar")
      expect(req.cookies[session_key]).to eq("session_data")
    end
  end

  context "when a SessionRestoreError is raised" do
    it "rescues the error, clears session and cookie data, and retries the call" do
      middleware = described_class.new(bad_app)
      status, headers, body = middleware.call(env)
      expect(status).to eq(200)
      expect(body).to eq(%w[OK])

      req = ActionDispatch::Request.new(headers)
      expect(req.env["rack.session"]).to be_nil
      expect(req.env["rack.session.options"]).to be_nil
      expect(req.cookies["other_cookie"]).to eq("bar")
      expect(req.cookies[session_key]).to eq(nil)
    end
  end
end
