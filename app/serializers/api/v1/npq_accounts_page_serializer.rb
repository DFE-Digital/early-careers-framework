# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class NPQAccountsPageSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      attributes :lead_provider_approval_status, :id, :participant_outcome_state
      attribute(:participant_outcome_state) do |object|
        ParticipantOutcome::NPQ.where(participant_declaration_id: ParticipantDeclaration.where(user_id: object.user_id))&.order("completion_date desc")&.limit(1)&.first&.state
      end
    end
  end
end
