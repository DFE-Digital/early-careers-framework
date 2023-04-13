# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class ParticipantOutcomeSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      set_id :id
      set_type :'participant-outcome'

      attribute :state
      attribute :completion_date do |outcome|
        outcome.completion_date.rfc3339
      end

      attribute :course_identifier do |outcome|
        outcome.participant_declaration.course_identifier
      end

      attribute :participant_id do |outcome|
        outcome.participant_declaration.participant_profile.participant_identity.user_id
      end

      attribute :created_at do |outcome|
        outcome.created_at.rfc3339
      end
    end
  end
end
