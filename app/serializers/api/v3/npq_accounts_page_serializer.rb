# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V3
    class NPQAccountsPageSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      attributes :lead_provider_approval_status, :id
    end
  end
end
