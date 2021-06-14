# frozen_string_literal: true

class ParticipantEventAggregator
  def self.call(lead_provider)
    ParticipantDeclaration
      .active
      .joins(:early_career_teacher_profile)
      .where(lead_provider: lead_provider)
      .count
  end
end
