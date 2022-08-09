# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V2
    class NPQApplicationSerializer < V1::NPQApplicationSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      attribute(:targeted_delivery_funding_eligibility)
    end
  end
end
