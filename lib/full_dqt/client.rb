# frozen_string_literal: true

require "net/http"

module FullDqt
  class Client
    attr_reader :token

    def initialize(token:)
      @token = token
    end

    def get_record(trn:, birthdate:, nino: nil)
      uri_for_record = uri(trn: trn, birthdate: birthdate, nino: nino)

      request = Net::HTTP::Get.new(uri_for_record)
      request["Authorization"] = "Bearer #{token}"
      request["Ocp-Apim-Subscription-Key"] = subscription_key

      response = Net::HTTP.start(uri_for_record.hostname, uri_for_record.port, use_ssl: true, read_timeout: 20) do |http|
        http.request(request)
      end

      if response.code == "200"
        translate_hash(JSON.parse(response.body))
      end
    end

  private

    def translate_hash(hash)
      hash.deep_transform_values do |value|
        if value =~ /^\d{4}-\d{2}-\d{2}/
          Date.parse(value)
        else
          value
        end
      end
    end

    def subscription_key
      Rails.configuration.dqt_api_ocp_apim_subscription_key
    end

    def uri(trn:, birthdate:, nino: nil)
      URI("#{Rails.configuration.dqt_api_url}/#{trn}?#{query_string_object(birthdate: birthdate, nino: nino).to_query}")
    end

    def query_string_object(birthdate:, nino: nil)
      object = {
        birthdate: birthdate,
      }

      object[:nino] = nino if nino

      object
    end
  end
end
