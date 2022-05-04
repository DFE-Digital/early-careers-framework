# frozen_string_literal: true

module Finance
  module ECF
    class ParticipantAggregator < Finance::ParticipantAggregator
      def self.aggregation_types
        {
          started: {
            all: :unique_id,
            uplift: :unique_uplift,
            ects: :unique_ects,
            mentors: :unique_mentors,
          },
          retained_1: {
            all: :unique_id,
            uplift: :unique_uplift,
            ects: :unique_ects,
            mentors: :unique_mentors,
          },
          retained_2: {
            all: :unique_id,
            uplift: :unique_uplift,
            ects: :unique_ects,
            mentors: :unique_mentors,
          },
          retained_3: {
            all: :unique_id,
            uplift: :unique_uplift,
            ects: :unique_ects,
            mentors: :unique_mentors,
          },
          retained_4: {
            all: :unique_id,
            uplift: :unique_uplift,
            ects: :unique_ects,
            mentors: :unique_mentors,
          },
          completed: {
            all: :unique_id,
            uplift: :unique_uplift,
            ects: :unique_ects,
            mentors: :unique_mentors,
          },
        }
      end
    end
  end
end
