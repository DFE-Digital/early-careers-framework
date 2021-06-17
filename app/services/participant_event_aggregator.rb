# frozen_string_literal: true

class ActiveParticipantAggregator
  class << self
    def call(lead_provider:)
      new.call(lead_provider: lead_provider)
    end
  end

  def initialize(participant_declaration_class: ParticipantDeclaration)
    @participant_declaration_class = participant_declaration_class
  end

  def call(lead_provider:)
    @participant_declaration_class.count_active_for_lead_provider(lead_provider)
  end
end
