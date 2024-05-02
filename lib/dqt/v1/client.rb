# frozen_string_literal: true

require "net/http"

# We only use this V1 API client for an additional check when no match is found
# on the V3 API using a TRN. This endpoint allows us to query by NiNo and DoB.
# TRN is a valid parameter but TRN searches should be done using the V3 Client.
#
module DQT
  module V1
    class Client < DQT::Client
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
