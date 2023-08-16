# frozen_string_literal: true

module Dashboard
  class Participant
    attr_reader :induction_record, :participant_profile_id

    def initialize(induction_record:, participant_profile_id:)
      @induction_record = induction_record
      @participant_profile_id = induction_record&.participant_profile_id || participant_profile_id
    end

    # completed_induction?
    delegate :completed_induction?, to: :participant_profile

    def full_name
      induction_record&.participant_full_name || participant_profile.full_name
    end

    # induction_completion_date
    delegate :induction_completion_date, to: :participant_profile

    # induction_start_date
    delegate :induction_start_date, to: :participant_profile

    def participant_profile
      @participant_profile ||= ParticipantProfile.find(participant_profile_id)
    end

    def mentor
      induction_record.mentor_profile
    end

    def mentored?
      induction_record&.mentor_profile_id.present?
    end
  end
end
