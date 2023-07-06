# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    module NPQ
      class ApplicationSynchronizationSerializer
        include JSONAPI::Serializer
        include JSONAPI::Serializer::Instrumentation

        attributes :id, :lead_provider_approval_status, :participant_outcome_state

        attribute(:participant_outcome_state) do |application|
          ApplicationStatusQuery.new(application).call
        end
      end
    end
  end
end
