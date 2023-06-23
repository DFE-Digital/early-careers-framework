# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    module NPQ
      class ApplicationSynchronizationSerializer
        include JSONAPI::Serializer
        include JSONAPI::Serializer::Instrumentation

        attributes :lead_provider_approval_status, :id, :participant_outcome_state
        attribute(:participant_outcome_state) do |object|
          object.latest_declaration_of_user&.latest_outcome_of_declaration if object.latest_declaration_of_user.present?
        end
      end
    end
  end
end
