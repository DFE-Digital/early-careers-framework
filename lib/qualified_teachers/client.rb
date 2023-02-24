# frozen_string_literal: true

require "net/http"

module QualifiedTeachers
  class Client
    THROTTLING_ERROR_CODES = %w[429 503].freeze

    def send_record(trn:, request_body:)
      raise "Qualified Teachers API Key is not present" if api_key.blank?

      uri_for_record = uri(trn:)

      request = Net::HTTP::Put.new(uri_for_record)
      request["Authorization"] = "Bearer #{api_key}"
      request["Content-Type"] = "application/json"

      response = Net::HTTP.start(uri_for_record.hostname, uri_for_record.port, use_ssl: true, read_timeout: 30) do |http|
        http.request(request, request_body.to_json)
      end

      raise(TooManyRequests, "Too Many Requests") if THROTTLING_ERROR_CODES.include?(response.code)

      OpenStruct.new(
        request:,
        response:,
      )
    end

  private

    def api_key
      Rails.configuration.qualified_teachers_api_key
    end

    def uri(trn:)
      URI("#{Rails.configuration.qualified_teachers_api_url}/v2/npq-qualifications?trn=#{trn}")
    end
  end
end

class TooManyRequests < StandardError; end
