# frozen_string_literal: true

require "has_di_parameters"

class ParticipantUpliftAggregator
  include HasDIParameters

  def call(event_type: :started)
    recorder.send(params[event_type], lead_provider)
  end

private

  def default_params
    {
      recorder: ParticipantDeclaration,
      started: :count_active_uplift_for_lead_provider,
    }
  end
end
