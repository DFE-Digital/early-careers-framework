# frozen_string_literal: true

require "initialize_with_config"

class ParticipantEventAggregator
  include InitializeWithConfig

  def call(event_type: :start)
    recorder.send(config[event_type], lead_provider)
  end

private

  def default_config
    {
      recorder: ParticipantDeclaration,
      start: :count_active_for_lead_provider,
    }
  end
end
