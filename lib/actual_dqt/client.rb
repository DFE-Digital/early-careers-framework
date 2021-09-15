# frozen_string_literal: true

require "net/http"

module ActualDqt
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
        JSON.parse(response.body)
      end
    end

  private

    def subscription_key
      Rails.configuration.dqt_api_ocp_apim_subscription_key
    end

    def uri(trn:, birthdate:, nino: nil)
      URI("#{Rails.configuration.dqt_api_url}/#{trn}?#{query_string(birthdate: birthdate, nino: nino)}")
    end

    def query_string(birthdate:, nino: nil)
      array = []
      array << "birthdate=#{birthdate}"
      array << "nino=#{nino}" if nino
      array.join("&")
    end
  end
end
