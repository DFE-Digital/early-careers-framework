# frozen_string_literal: true

require "abstract_interface"

module Finance
  class ParticipantAggregator
    include AbstractInterface
    implement_class_method :aggregation_types

    EVENT_TYPE_TO_DECLARATION_TYPE_MAP = {
      started: "started",
      retained_1: "retained-1",
      retained_2: "retained-2",
      retained_3: "retained-3",
      retained_4: "retained-4",
      completed: "completed",
    }.freeze

    def call(event_type: :started)
      aggregations(event_type:).tap do |h|
        h[:previous_participants] =
          recorder
          .where(statement: previous_statements)
          .public_send(event_type)
          .count
      end
    end

  private

    attr_reader :statement, :cpd_lead_provider, :recorder

    def initialize(statement:, recorder: ParticipantDeclaration::ECF)
      @statement = statement
      @cpd_lead_provider = statement.cpd_lead_provider
      @recorder = recorder
    end

    def aggregators(event_type:)
      Hash.new do |hash, key|
        hash[key] = aggregate(aggregation_type: key, event_type:)
      end
    end

    def previous_statements
      Finance::Statement::ECF.where(
        deadline_date: ..(statement.deadline_date - 1.day),
        cpd_lead_provider: statement.cpd_lead_provider,
      )
    end

    def aggregate(aggregation_type:, event_type:)
      statement
        .participant_declarations
        .public_send(self.class.aggregation_types[event_type][aggregation_type])
        .where(declaration_type: EVENT_TYPE_TO_DECLARATION_TYPE_MAP[event_type])
        .count
    end

    def aggregations(event_type:)
      self.class.aggregation_types[event_type].keys.index_with do |key|
        aggregators(event_type:)[key]
      end
    end
  end
end
