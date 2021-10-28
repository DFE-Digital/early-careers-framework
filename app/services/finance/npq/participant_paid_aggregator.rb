# frozen_string_literal: true

module Finance
  module NPQ
    class ParticipantPaidAggregator < ParticipantEligibleAggregator
      class << self
        def aggregation_types
          {
            started: {
              not_yet_included: :not_paid_for_lead_provider,
              all: :paid_for_lead_provider,
            },
          }
        end
      end
    end
  end
end
