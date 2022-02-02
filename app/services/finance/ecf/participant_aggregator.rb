# frozen_string_literal: true

module Finance
  module ECF
    class ParticipantAggregator < Finance::ParticipantAggregator
      def self.aggregation_types
        {
          started: {
            # not_yet_included: :not_eligible_for_lead_provider,
            all: :unique_for_lead_provider,
            uplift: :unique_uplift_for_lead_provider,
            ects: :unique_ects_for_lead_provider,
            mentors: :unique_mentors_for_lead_provider,
          },
          retained_1: {
            # not_yet_included: :not_eligible_for_lead_provider,
            all: :unique_for_lead_provider,
            uplift: :unique_uplift_for_lead_provider,
            ects: :unique_ects_for_lead_provider,
            mentors: :unique_mentors_for_lead_provider,
          },
        }
      end
    end
  end
end
