# frozen_string_literal: true

class ParticipantProfileResolver
  class << self
    def call(participant_identity:, course_identifier:)
      return unless participant_identity

      if ParticipantProfile::ECT::COURSE_IDENTIFIERS.include?(course_identifier)
        participant_identity
          .participant_profiles
          .active_record
          .ects
          .first
      elsif ParticipantProfile::Mentor::COURSE_IDENTIFIERS.include?(course_identifier)
        participant_identity
          .participant_profiles
          .active_record
          .mentors
          .first
      end
    end
  end
end
