# frozen_string_literal: true

class ParticipantEventAggregator
  def self.call(lead_provider)
    active = ParticipantDeclaration
      .active
      .joins(:early_career_teacher_profile)
      .where(lead_provider: lead_provider)
      .count

    uplift = ParticipantDeclaration
      .active
      .joins(:early_career_teacher_profile)
      .where(lead_provider: lead_provider)
      .where("early_career_teacher_profiles.uplift = true")
      .count

    [active, uplift]
  end
end
