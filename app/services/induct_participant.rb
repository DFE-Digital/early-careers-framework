# frozen_string_literal: true

class InductParticipant
  include InitializeWithConfig

  def call
    recorder.find_or_initialize_by(lead_provider: lead_provider, early_career_teacher_profile: early_career_teacher_profile).join!
  rescue AASM::InvalidTransition
    false
  end

private

  def default_config
    {
      recorder: ParticipationRecord,
    }
  end
end
