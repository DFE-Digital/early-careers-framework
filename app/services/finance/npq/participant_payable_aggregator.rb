# frozen_string_literal: true

module Finance
  module NPQ
    class ParticipantPayableAggregator < ParticipantEligibleAggregator
      class << self
        def aggregation_types
          {
            started: {
              not_payable: :not_payable_for_lead_provider,
              all: :payable_for_lead_provider,
            },
          }
        end
      end
    end
  end
end
