# frozen_string_literal: true

module Finance
  module ECF
    class ParticipantAggregator < Finance::ParticipantAggregator
      def self.aggregation_types
        {
          started: {
            all: :unique_for_lead_provider,
            uplift: :unique_uplift_for_lead_provider,
            ects: :unique_ects_for_lead_provider,
            mentors: :unique_mentors_for_lead_provider,
          },
          retained_1: {
            all: :unique_for_lead_provider,
            uplift: :unique_uplift_for_lead_provider,
            ects: :unique_ects_for_lead_provider,
            mentors: :unique_mentors_for_lead_provider,
          },
          retained_2: {
            all: :unique_for_lead_provider,
            uplift: :unique_uplift_for_lead_provider,
            ects: :unique_ects_for_lead_provider,
            mentors: :unique_mentors_for_lead_provider,
          },
          retained_3: {
            all: :unique_for_lead_provider,
            uplift: :unique_uplift_for_lead_provider,
            ects: :unique_ects_for_lead_provider,
            mentors: :unique_mentors_for_lead_provider,
          },
          retained_4: {
            all: :unique_for_lead_provider,
            uplift: :unique_uplift_for_lead_provider,
            ects: :unique_ects_for_lead_provider,
            mentors: :unique_mentors_for_lead_provider,
          },
          completed: {
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
