# frozen_string_literal: true

class InductParticipant
  attr_accessor :participant_profile

  class << self
    def call(early_career_teacher_profile)
      new(early_career_teacher_profile).call
    end
  end

  def call
    participant_profile.join!
  rescue AASM::InvalidTransition
    # ignore it for now as it's possible the client may call the same API more than once
  end

private

  def initialize(early_career_teacher_profile)
    self.participant_profile = ParticipationRecord.find_or_initialize_by(early_career_teacher_profile: early_career_teacher_profile)
  end
end
