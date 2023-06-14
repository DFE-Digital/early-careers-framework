# frozen_string_literal: true

module Dashboard
  class Participant
    attr_reader :induction_record, :participant_profile_id

    def initialize(induction_record:, participant_profile_id:)
      @induction_record = induction_record
      @participant_profile_id = induction_record&.participant_profile_id || participant_profile_id
    end

    def full_name
      induction_record&.participant_full_name || participant_profile.full_name
    end

    def participant_profile
      @participant_profile ||= ParticipantProfile.find(participant_profile_id)
    end
  end
end
