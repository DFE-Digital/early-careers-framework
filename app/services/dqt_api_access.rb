# frozen_string_literal: true

require "net/http"
require "jwt"

class DqtApiAccess
  class << self
    def token
      if @token.nil? || token_about_to_expire?
        request = Net::HTTP::Get.new(uri)

        data = {
          grant_type: grant_type,
          scope: scope,
          client_id: client_id,
          client_secret: client_secret,
        }

        request.set_form_data(data)

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: use_ssl?, read_timeout: 20) do |http|
          http.request(request)
        end

        if response.code == "200"
          @token = JSON.parse(response.body)["access_token"]
        else
          raise "DQT access token could not be fetched"
        end
      end

      @token
    end

  private

    def token_about_to_expire?
      expires_at = Time.zone.at(decoded_token.dig(0, "exp"))
      Time.zone.now + token_expiry_leeway > expires_at
    end

    def decoded_token
      JWT.decode @token, nil, false
    end

    def token_expiry_leeway
      5.minutes
    end

    def grant_type
      "client_credentials"
    end

    def scope
      Rails.configuration.dqt_access_scope
    end

    def client_id
      Rails.configuration.dqt_access_client_id
    end

    def client_secret
      Rails.configuration.dqt_access_client_secret
    end

    def uri
      URI(Rails.configuration.dqt_access_url)
    end

    def use_ssl?
      uri.scheme == "https"
    end
  end
end
