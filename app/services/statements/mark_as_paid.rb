module Statements
  class MarkAsPaid
    def initialize(statement)
      self.statement = statement
    end

    def call
      statement.
    end

    private

    def orchestrator
    Finance::NPQ::CalculationOrchestrator.new(
      aggregator: aggregator,
      contract: cpd_lead_provider.lead_provider.call_off_contract,
      statement: self,
    )
  end

  def aggregator
    Finance::NPQ::ParticipantAggregator.new(
      statement: self,
      recorder: ParticipantDeclaration::NPQ.where.not(state: %w[voided]),
    )
  end

  end
end
