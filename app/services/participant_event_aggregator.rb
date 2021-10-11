# frozen_string_literal: true

class ParticipantEventAggregator
  class << self
    def call(cpd_lead_provider:, recorder: ParticipantDeclaration::ECF, event_type: started)
      new(cpd_lead_provider: cpd_lead_provider, recorder: recorder).call(event_type: event_type)
    end
  end

  def call(event_type: :started)
    aggregations(event_type: event_type)
  end

private

  attr_reader :cpd_lead_provider, :recorder

  def initialize(cpd_lead_provider:, recorder: ParticipantDeclaration::ECF)
    @cpd_lead_provider = cpd_lead_provider
    @recorder = recorder
  end

  def aggregators(event_type:)
    @aggregators ||= Hash.new { |hash, key| hash[key] = aggregate(aggregation_type: key, event_type: event_type) }
  end

  def aggregate(aggregation_type:, event_type:)
    recorder.send(aggregation_types[event_type][aggregation_type], cpd_lead_provider).count
  end

  def aggregation_types
    {
      started: {
        all: :eligible_for_lead_provider,
        uplift: :eligible_uplift_for_lead_provider,
        ects: :eligible_ects_for_lead_provider,
        mentors: :eligible_mentors_for_lead_provider,
      },
    }
  end

  def aggregations(event_type:)
    aggregation_types[event_type].keys.index_with do |key|
      aggregators(event_type: event_type)[key]
    end
  end
end
