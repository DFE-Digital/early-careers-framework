# frozen_string_literal: true

module Dashboard
  class Participant
    attr_reader :induction_record, :participant_profile_id

    def initialize(induction_record:, participant_profile_id:)
      @induction_record = induction_record
      @participant_profile_id = induction_record&.participant_profile_id || participant_profile_id
    end

    delegate :completed_induction?,
             :induction_completion_date,
             :induction_start_date,
             :mentor?,
             :ect?,
             :id,
             to: :participant_profile

    delegate :mentor_profile_id, to: :induction_record, allow_nil: true

    def full_name
      induction_record&.participant_full_name || participant_profile.full_name
    end

    def mentor
      induction_record.mentor_profile
    end

    def mentored?
      induction_record&.mentor_profile_id.present?
    end

    def participant_profile
      @participant_profile ||= ParticipantProfile.find(participant_profile_id)
    end
  end
end
