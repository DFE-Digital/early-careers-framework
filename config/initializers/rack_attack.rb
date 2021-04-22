# frozen_string_literal: true

# Throttle general requests by IP
class Rack::Attack
  throttle("General requests by ip", limit: 300, period: 5.minutes, &:ip)

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
