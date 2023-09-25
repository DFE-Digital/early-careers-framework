# frozen_string_literal: true

# Throttle general requests by IP
class Rack::Attack
  API_PATH = "/api/"

  # Throttle /csp_reports requests by IP (5rpm)
  throttle("csp_reports req/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/csp_reports"
  end

  safelist("Allow notify callbacks at any rate") do |request|
    request.path == "/api/notify-callback" && request.post?
  end

  throttle("Non-API requests by ip", limit: 300, period: 5.minutes) do |request|
    unless request.path.starts_with?(API_PATH)
      request.ip
    end
  end

  throttle("API requests by ip", limit: 1000, period: 5.minutes) do |request|
    if request.path.starts_with?(API_PATH)
      request.get_header("HTTP_AUTHORIZATION")
    end
  end

  throttle("Login attempts by ip", limit: 5, period: 20.seconds) do |request|
    if request.path == "/users/sign_in" && request.post?
      request.ip
    end
  end
end

ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, request_id, payload|
  ip = payload[:request].ip
  path = payload[:request].fullpath

  Rails.logger.warn("[rack-attack] Throttled request #{request_id} from #{ip} to '#{path}'")
end
