# frozen_string_literal: true

class InductParticipant
  include InitializeWithConfig

  def call
    event_recorder.find_or_initialize_by(early_career_teacher_profile: early_career_teacher_profile).join!
  rescue AASM::InvalidTransition
    false
  end

  private

  def default_config
    {
      event_recorder: ParticipationRecord
    }
  end
end
