# frozen_string_literal: true

class ParticipantIdentityResolver
  def initialize(participant_id:, course_identifier:)
    @participant_id = participant_id
    @course_identifier = course_identifier
  end

  def self.call(**args)
    new(**args).call
  end

  def call
    return if participant_id.blank?

    participant_identity =
      if ParticipantProfile::ECT::COURSE_IDENTIFIERS.include?(course_identifier)
        ParticipantIdentity
         .joins(:participant_profiles)
         .where(participant_profiles: { type: "ParticipantProfile::ECT" })
         .where(user_id: participant_id)
         .first
      elsif ParticipantProfile::Mentor::COURSE_IDENTIFIERS.include?(course_identifier)
        ParticipantIdentity
         .joins(:participant_profiles)
         .where(participant_profiles: { type: "ParticipantProfile::Mentor" })
         .where(user_id: participant_id)
         .first
      end

    participant_identity.presence || ParticipantIdentity.find_by(external_identifier: participant_id)
  end

private

  attr_reader :participant_id, :course_identifier
end
