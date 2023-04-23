# frozen_string_literal: true

require "net/http"
require_relative "record"

module FullDQT
  class Client
    def get_record(trn:, birthdate:, nino: nil)
      uri_for_record = uri(trn:, birthdate:, nino:)

      request = Net::HTTP::Get.new(uri_for_record)
      request["Authorization"] = "Bearer #{api_key}"

      response = Net::HTTP.start(uri_for_record.hostname, uri_for_record.port, use_ssl: true, read_timeout: 20) do |http|
        http.request(request)
      end

      FullDQT::Record.new(response.code == "200" ? translate_hash(JSON.parse(response.body)) : {})
    end

  private

    def translate_hash(hash)
      hash.deep_transform_values do |value|
        case value
        when /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/
          Time.zone.parse(value)
        when /^\d{4}-\d{2}-\d{2}/
          Date.parse(value)
        else
          value
        end
      end
    end

    def api_key
      Rails.configuration.dqt_api_key
    end

    def uri(trn:, birthdate:, nino: nil)
      URI("#{Rails.configuration.dqt_api_url}/v1/teachers/#{trn}?#{query_string_object(birthdate:, nino:).to_query}")
    end

    def query_string_object(birthdate:, nino: nil)
      object = {
        birthdate:,
      }

      object[:nino] = nino if nino

      object
    end
  end
end
