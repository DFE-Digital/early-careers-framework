# frozen_string_literal: true

module Finance
  module ECF
    class ParticipantAggregator < Finance::ParticipantAggregator
      def self.aggregation_types
        {
          started: {
            # not_yet_included: :not_eligible_for_lead_provider,
            all: :unique_id,
            uplift: :unique_uplift,
            ects: :unique_ects,
            mentors: :unique_mentors,
          },
          retained_1: {
            # not_yet_included: :not_eligible_for_lead_provider,
            all: :unique_id,
            ects: :unique_ects,
            mentors: :unique_mentors,
            uplift: :unique_uplift,
          },
        }
      end
    end
  end
end
