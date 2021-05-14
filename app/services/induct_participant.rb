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
  end

private

  def initialize(early_career_teacher_profile)
    self.participant_profile = ParticipationRecord.new(early_career_teacher_profile: early_career_teacher_profile)
  end
end
