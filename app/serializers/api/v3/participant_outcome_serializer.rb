# frozen_string_literal: true

module Api
  module V3
    class ParticipantOutcomeSerializer < V1::ParticipantOutcomeSerializer
      set_type :'participant-outcome'

      attribute :updated_at do |outcome|
        outcome.updated_at.rfc3339
      end
    end
  end
end
