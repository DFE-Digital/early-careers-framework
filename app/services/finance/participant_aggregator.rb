# frozen_string_literal: true

require "abstract_interface"

module Finance
  class ParticipantAggregator
    include AbstractInterface
    implement_class_method :aggregation_types

    class << self
      def call(cpd_lead_provider:, interval: nil, recorder: ParticipantDeclaration::ECF, event_type: :started)
        new(cpd_lead_provider: cpd_lead_provider, recorder: recorder).call(event_type: event_type, interval: interval)
      end
    end

    def call(interval: nil, event_type: :started)
      aggregations(event_types: event_type, interval: interval)
    end

  private

    attr_reader :cpd_lead_provider, :recorder

    def initialize(cpd_lead_provider:, recorder: ParticipantDeclaration::ECF)
      @cpd_lead_provider = cpd_lead_provider
      @recorder = recorder
    end

    def aggregators(event_type:, interval:)
      @aggregators ||= Hash.new { |hash, key| hash[key] = aggregate(aggregation_type: key, event_type: event_type, interval: interval) }
    end

    def aggregate(aggregation_type:, event_type:, interval: nil)
      scope = recorder.public_send(self.class.aggregation_types[event_type][aggregation_type], cpd_lead_provider)
      scope = scope.submitted_between(interval.begin, interval.end) if interval.present?
      scope.count
    end

    def aggregations(event_types:, interval:)
      event_types.each do |event_type|
        self.class.aggregation_types[event_type].keys.index_with do |key|
          aggregators(event_type: event_type, interval: interval)[key]
        end
      end
    end
  end
end
