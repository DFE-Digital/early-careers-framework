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
          ParticipantOutcome::NPQ.participant_outcome_of_user(object.user_id)&.first&.state
        end
      end
    end
  end
end
