# frozen_string_literal: true

require "abstract_interface"

module Finance
  class ParticipantAggregator
    include AbstractInterface
    implement_class_method :aggregation_types

    class << self
      def call(cpd_lead_provider:, interval: nil, participant_declaration: ParticipantDeclaration::ECF, event_type: :started)
        new(cpd_lead_provider: cpd_lead_provider, participant_declaration: participant_declaration).call(event_type: event_type, interval: nil)
      end
    end

    def call(interval: nil, event_type: :started)
      aggregations(event_type: event_type, interval: interval)
    end

  private

    attr_reader :cpd_lead_provider, :participant_declaration

    def initialize(cpd_lead_provider:, participant_declaration: ParticipantDeclaration::ECF)
      self.cpd_lead_provider = cpd_lead_provider
      self.participant_declaration = participant_declaration
    end

    def aggregators(event_type:, interval:)
      @aggregators ||= Hash.new { |hash, key| hash[key] = aggregate(aggregation_type: key, event_type: event_type, interval: interval) }
    end

    def aggregate(aggregation_type:, event_type:, interval: nil)
      scope = participant_declaration.public_send(self.class.aggregation_types[event_type][aggregation_type], cpd_lead_provider)
      scope = scope.submitted_between(interval.begin, interval.end) if interval.present?
      scope.count
    end

    def aggregations(event_type:, interval:)
      self.class.aggregation_types[event_type].keys.index_with do |key|
        aggregators(event_type: event_type, interval: interval)[key]
      end
    end
  end
end
