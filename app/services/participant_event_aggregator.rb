# frozen_string_literal: true

class ActiveParticipantAggregator
  # We could add this as a convenience to allow calling with default dependencies without `new`, but it's not too important
  # class << self
  #   def call(lead_provider:)
  #     new.call(lead_provider: lead_provider)
  #   end
  # end
  #
  def initialize(participant_declaration_class: ParticipantDeclaration)
    @participant_declaration_class = participant_declaration_class
  end

  def call(lead_provider:)
    @participant_declaration_class.count_active_for_lead_provider(lead_provider)
  end
end
