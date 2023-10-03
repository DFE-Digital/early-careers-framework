# frozen_string_literal: true

require "rails_helper"

describe FixAzureXForwardedForMiddleware do
  let(:env) { Rack::MockRequest.env_for }
  let(:mock_app) { ->(_env) { [200, {}, "success"] } }

  subject(:app) { described_class.new(mock_app) }

  it "removes ports from IP addresses in the HTTP_X_FORWARDED_FOR header" do
    ip_address1 = "1.2.3.4"
    ip_address2 = "5.6.7.8"
    env["HTTP_X_FORWARDED_FOR"] = "#{ip_address1}:80,#{ip_address2}:443"

    app.call(env)

    expect(env).to include({ "HTTP_X_FORWARDED_FOR" => "#{ip_address1},#{ip_address2}" })
  end
end
