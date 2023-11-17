# frozen_string_literal: true

# Throttle general requests by IP
class Rack::Attack
  class Request < ::Rack::Request
    def remote_ip
      # This will always be present because the ActionDispatch::RemoteIp
      # middleware runs long before this middleware. Use #fetch here
      # so that we bail quickly if that middleware goes away or changes
      # the field name. Have preferred this to instantiating a whole
      # ActionDispatch::Request as that's a whole lot of work and this happens
      # on every request.
      #
      # Favour the X-Real-IP header if set by Azure, if not fallback to
      # ActionDispatch#remote_ip which is more reliable than Rack's ip method.
      @remote_ip ||= env.fetch("x-real-ip", nil).presence || env.fetch("action_dispatch.remote_ip").to_s
    end
  end

  API_PATH = "/api/"

  # Throttle /csp_reports requests by IP (5rpm)
  throttle("csp_reports req/ip", limit: 5, period: 1.minute) do |req|
    req.remote_ip if req.path == "/csp_reports"
  end

  safelist("Allow notify callbacks at any rate") do |request|
    request.path == "/api/notify-callback" && request.post?
  end

  safelist("Allow /check endpoint at any rate") do |request|
    request.path == "/check"
  end

  throttle("Login attempts by ip", limit: 5, period: 20.seconds) do |request|
    if request.path == "/users/sign_in" && request.post?
      request.remote_ip
    end
  end

  throttle("API requests by ip", limit: 1000, period: 5.minutes) do |request|
    if request.path.starts_with?(API_PATH)
      request.get_header("HTTP_AUTHORIZATION")
    end
  end

  throttle("Non-API requests by ip", limit: 300, period: 5.minutes) do |request|
    unless request.path.starts_with?(API_PATH)
      request.remote_ip
    end
  end
end

ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, request_id, payload|
  request = ActionDispatch::Request.new(payload[:request].env)
  response = ActionDispatch::Response.new(429)

  ip = request.remote_ip
  path = request.fullpath
  user = request.env["warden"]&.user

  Rails.logger.warn("[rack-attack] Throttled request #{request_id} from #{ip} to '#{path}'")

  # Web requests are sent to BigQuery via a concern in the ApplicationController.
  # If Rack intercepts the request it won't reach the controller, so we need
  # to manually send web requests that are rate limited to BigQuery.
  if DfE::Analytics.enabled?
    rate_limit_event = DfE::Analytics::Event.new
      .with_type(:web_request)
      .with_request_details(request)
      .with_response_details(response)
      .with_request_uuid(request.uuid)

    rate_limit_event.with_user(user) if user.respond_to?(:id)

    DfE::Analytics::SendEvents.do([rate_limit_event])
  end
end
