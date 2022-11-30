# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class ParticipantOutcomeSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      set_id :id
      set_type :'participant-outcome'

      attribute :completion_date do |outcome|
        outcome.completion_date.rfc3339
      end
      attribute :course_identifier do |outcome|
        outcome.participant_declaration.course_identifier
      end

      attribute :participant_id do |outcome|
        outcome.participant_declaration.participant_profile.npq_application.participant_identity.external_identifier
      end
    end
  end
end
