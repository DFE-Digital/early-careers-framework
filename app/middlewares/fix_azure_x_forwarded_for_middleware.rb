# frozen_string_literal: true

class FixAzureXForwardedForMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # ActionDispatch::RemoteIp::GetIp does not support IP addresses with
    # ports included in the CLIENT_IP or X_FORWARDED_FOR headers. Azure includes
    # ports with these IPs, so they're ignored when remote_ip is calculated.
    #
    # In practice this means remote_ip always returns REMOTE_ADDR on Azure,
    # even though it falls within 172.16.0.0/12 and is therefore known to be
    # a private IP.
    #
    # Rack has solved this issue long ago: https://github.com/rack/rack/issues/1227
    # so use Rack's own parsing to overwrite this header before it
    # gets to ActionDispatch::RemoteIp
    req = Rack::Request.new(env)

    if req.forwarded_for.present?
      env["HTTP_X_FORWARDED_FOR"] = req.forwarded_for.join(",")
    end

    @app.call(env)
  end
end
