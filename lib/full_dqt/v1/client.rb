# frozen_string_literal: true

require "net/http"

# NOTE: Use this API for validation of participant data
#
module FullDQT
  module V1
    class Client
      def get_record(trn:, birthdate:, nino: nil)
        call_api(uri: endpoint_uri(trn:, birthdate:, nino:))
      end

    private

      def call_api(uri:)
        request = Net::HTTP::Get.new(uri)
        request["Authorization"] = "Bearer #{api_key}"

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 20) do |http|
          http.request(request)
        end

        if response.code == "200"
          translate_hash(JSON.parse(response.body))
        end
      end

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

      def api_url
        Rails.configuration.dqt_api_url
      end

      def endpoint_uri(trn:, birthdate:, nino: nil)
        URI("#{api_url}/v1/teachers/#{trn}?#{query_string_object(birthdate:, nino:).to_query}")
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
end
