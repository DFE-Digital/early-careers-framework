# frozen_string_literal: true

module Finance
  module ECF
    class ParticipantPayableAggregator < Finance::ParticipantAggregator
      class << self
        def aggregation_types
          {
            started: {
              not_yet_included: :not_payable_for_lead_provider,
              all: :payable_for_lead_provider,
              uplift: :payable_uplift_for_lead_provider,
              ects: :payable_ects_for_lead_provider,
              mentors: :payable_mentors_for_lead_provider,
            },
            retained_1: {
              not_yet_included: :not_payable_for_lead_provider,
              all: :payable_for_lead_provider,
              uplift: :payable_uplift_for_lead_provider,
              ects: :payable_ects_for_lead_provider,
              mentors: :payable_mentors_for_lead_provider,
            },
          }
        end
      end
    end
  end
end
