# frozen_string_literal: true

class ParticipantEventPayableAggregator < ParticipantEventAggregator

private

  def aggregation_types
    {
      started: {
        all: :payable_for_lead_provider,
        uplift: :payable_uplift_for_lead_provider,
        ects: :payable_ects_for_lead_provider,
        mentors: :payable_mentors_for_lead_provider,
      },
    }
  end
end
