# frozen_string_literal: true

require "net/http"

# NOTE: Use this API for validation of participant data
#
module FullDQT
  module V1
    class Client < FullDQT::Client
      def get_record(trn:, birthdate:, nino: nil)
        call_api(uri: endpoint_uri(trn:, birthdate:, nino:))
      end

    private

      def endpoint_uri(trn:, birthdate:, nino: nil)
        URI("#{api_url}/v1/teachers/#{trn}?#{{ birthdate:, nino: }.compact.to_query}")
      end
    end
  end
end
