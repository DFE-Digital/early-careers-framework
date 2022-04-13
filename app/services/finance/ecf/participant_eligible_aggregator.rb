# frozen_string_literal: true

module Finance
  module ECF
    class ParticipantEligibleAggregator < Finance::ParticipantAggregator
      def self.aggregation_types
        {
          started: {
            not_yet_included: :not_eligible_for_lead_provider,
            all: :eligible_for_lead_provider,
            uplift: :eligible_uplift_for_lead_provider,
            ects: :eligible_ects_for_lead_provider,
            mentors: :eligible_mentors_for_lead_provider,
          },
          retained_1: {
            not_yet_included: :not_eligible_for_lead_provider,
            all: :eligible_for_lead_provider,
            uplift: :eligible_uplift_for_lead_provider,
            ects: :eligible_ects_for_lead_provider,
            mentors: :eligible_mentors_for_lead_provider,
          },
          retained_2: {
            not_yet_included: :not_eligible_for_lead_provider,
            all: :eligible_for_lead_provider,
            uplift: :eligible_uplift_for_lead_provider,
            ects: :eligible_ects_for_lead_provider,
            mentors: :eligible_mentors_for_lead_provider,
          },
          retained_3: {
            not_yet_included: :not_eligible_for_lead_provider,
            all: :eligible_for_lead_provider,
            uplift: :eligible_uplift_for_lead_provider,
            ects: :eligible_ects_for_lead_provider,
            mentors: :eligible_mentors_for_lead_provider,
          },
          retained_4: {
            not_yet_included: :not_eligible_for_lead_provider,
            all: :eligible_for_lead_provider,
            uplift: :eligible_uplift_for_lead_provider,
            ects: :eligible_ects_for_lead_provider,
            mentors: :eligible_mentors_for_lead_provider,
          },
          completed: {
            not_yet_included: :not_eligible_for_lead_provider,
            all: :eligible_for_lead_provider,
            uplift: :eligible_uplift_for_lead_provider,
            ects: :eligible_ects_for_lead_provider,
            mentors: :eligible_mentors_for_lead_provider,
          },
        }
      end

    private

      def aggregate(aggregation_type:, event_type:)
        scope = recorder.public_send(self.class.aggregation_types[event_type][aggregation_type], cpd_lead_provider)
        scope = scope.public_send(event_type)
        scope.count
      end
    end
  end
end
