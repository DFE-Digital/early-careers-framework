# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module NPQ
  class ParticipantProfileSerializer
    include JSONAPI::Serializer
    include JSONAPI::Serializer::Instrumentation

    set_type "npq-participant-profile"

    attribute(:participant_id) do |npq_participant_profile|
      npq_participant_profile.npq_application.user_id
    end

    attribute(:course_identifier) do |npq_participant_profile|
      npq_participant_profile.npq_course.identifier
    end

    attributes(:training_status)
  end
end
