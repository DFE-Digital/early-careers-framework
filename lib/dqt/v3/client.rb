# frozen_string_literal: true

require "net/http"

# NOTE: Use this API client for looking up information on a participant once
# we have validated their information using the V3 API.
#
# DO NOT USE THIS CLIENT FOR VALIDATION
#
module DQT
  module V3
    class Client < DQT::Client
      def get_record(trn:, date_of_birth: nil, sections: %w[induction])
        call_api(uri: endpoint_uri(trn:, date_of_birth:, sections:))
      end

    private

      def endpoint_uri(trn:, date_of_birth:, sections:)
        path = "/v3/teachers/#{trn}"
        params = { date_of_birth: }.compact
        params["include"] = sections.join(",") unless sections.empty?
        path += "?#{params.to_query}" unless params.empty?

        URI("#{api_url}#{path}")
      end
    end
  end
end
