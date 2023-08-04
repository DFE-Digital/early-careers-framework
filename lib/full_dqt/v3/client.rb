# frozen_string_literal: true

require "net/http"

# NOTE: Use this API client for looking up information on a participant once
# we have validated their information using the V1 API.
#
# DO NOT USE THIS CLIENT FOR VALIDATION
#
# (in theory at some point in the future we could use this for validation,
# but using the V1 API keeps the id matching logic on the API side whereas
# using the V3 API we would need to match and validate everything our side)
#
module FullDQT
  module V3
    class Client < V1::Client
      def get_record(trn:, sections: %w[induction])
        call_api(uri: endpoint_uri(trn:, sections:))
      end

    private

      def endpoint_uri(trn:, sections:)
        path = "/v3/teachers/#{trn}"
        path += "?include=#{sections.join(',')}" unless sections.empty?

        URI("#{api_url}#{path}")
      end
    end
  end
end
