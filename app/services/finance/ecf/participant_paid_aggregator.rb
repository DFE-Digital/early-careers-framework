# frozen_string_literal: true

module Finance
  module ECF
    class ParticipantPaidAggregator < Finance::ParticipantAggregator
      def self.aggregation_types
        {
          started: {
            not_yet_included: :not_paid_for_lead_provider,
            all: :paid_for_lead_provider,
            uplift: :paid_uplift_for_lead_provider,
            ects: :paid_ects_for_lead_provider,
            mentors: :paid_mentors_for_lead_provider,
          },
          retained_1: {
            not_yet_included: :not_paid_for_lead_provider,
            all: :paid_for_lead_provider,
            uplift: :paid_uplift_for_lead_provider,
            ects: :paid_ects_for_lead_provider,
            mentors: :paid_mentors_for_lead_provider,
          },
        }
      end
    end
  end
end
