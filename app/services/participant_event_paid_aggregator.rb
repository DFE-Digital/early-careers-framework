# frozen_string_literal: true

class ParticipantEventPayableAggregator < ParticipantEventAggregator

private

  def aggregation_types
    {
      started: {
        all: :paid_for_lead_provider,
        uplift: :paid_uplift_for_lead_provider,
        ects: :paid_ects_for_lead_provider,
        mentors: :paid_mentors_for_lead_provider,
      },
    }
  end
end
