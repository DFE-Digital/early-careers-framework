# frozen_string_literal: true

require "abstract_interface"

module Finance
  class ParticipantAggregator
    include AbstractInterface
    implement_class_method :aggregation_types

    def call(interval: nil, event_type: :started)
      aggregations(event_type: event_type, interval: interval)
    end

  private

    attr_reader :statement, :cpd_lead_provider, :recorder

    def initialize(statement:, recorder: ParticipantDeclaration::ECF)
      @statement = statement
      @cpd_lead_provider = statement.cpd_lead_provider
      @recorder = recorder
    end

    def aggregators(event_type:, interval:)
      @aggregators ||= Hash.new do |hash, key|
        hash[key] = aggregate(aggregation_type: key, event_type: event_type, interval: interval)
      end
    end

    def previous_statements
      Finance::Statement::ECF.where(
        deadline_date: ..(statement.deadline_date - 1.day),
        cpd_lead_provider: statement.cpd_lead_provider,
      )
    end

    def aggregate(aggregation_type:, event_type:, interval: nil)
      scope = recorder.public_send(self.class.aggregation_types[event_type][aggregation_type], cpd_lead_provider)
      scope = scope.where(statement_id: statement.id)
      scope = scope.public_send(event_type)
      scope = scope.submitted_between(interval.begin, interval.end) if interval.present?
      scope.count
    end

    def aggregations(event_type:, interval:)
      self.class.aggregation_types[event_type].keys.index_with do |key|
        aggregators(event_type: event_type, interval: interval)[key]
      end.tap do |h|
        h[:previous_participants] =
          recorder.where(statement: previous_statements).
          public_send(event_type).
          count
      end
    end
  end
end
