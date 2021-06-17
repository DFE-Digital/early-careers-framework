# frozen_string_literal: true

require "has_di_parameters"

class ParticipantEventAggregator
  include HasDIParameters

  def call(event_type: :started, lead_provider:)
    recorder.send(params[event_type], lead_provider)
  end

private

  def default_params
    {
      recorder: ParticipantDeclaration,
      started: :count_active_for_lead_provider,
    }
  end
end
