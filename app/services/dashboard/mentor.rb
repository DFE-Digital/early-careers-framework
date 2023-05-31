# frozen_string_literal: true

module Dashboard
  class Mentor
    attr_reader :induction_record, :participant_profile

    def initialize(induction_record:, participant_profile:)
      @induction_record = induction_record
      @participant_profile = participant_profile
    end

    def name
      induction_record&.participant_full_name || participant_profile.full_name
    end

    def participant_profile_id
      induction_record&.participant_profile_id || participant_profile.id
    end
  end
end
