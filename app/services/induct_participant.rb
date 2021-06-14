# frozen_string_literal: true

class InductParticipant
  class << self
    def call(lead_provider:, early_career_teacher_profile:, recorder: ParticipationRecord)
      new(recorder: recorder, lead_provider: lead_provider, early_career_teacher_profile: early_career_teacher_profile).call
    end
  end

  def call
    @recorder.find_or_initialize_by(lead_provider: @lead_provider, early_career_teacher_profile: @early_career_teacher_profile).join!
  rescue AASM::InvalidTransition
    false
  end

private

  def initialize(lead_provider:, early_career_teacher_profile:, recorder: ParticipationRecord)
    @lead_provider = lead_provider
    @early_career_teacher_profile = early_career_teacher_profile
    @recorder = recorder
  end
end
