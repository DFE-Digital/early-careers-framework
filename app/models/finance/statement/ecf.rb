# frozen_string_literal: true

class Finance::Statement::ECF < Finance::Statement
  def cache_original_value!
    breakdown_started = orchestrator.call(event_type: :started)
    breakdown_retained_1 = orchestrator.call(event_type: :retained_1)
    value = total_payment_combined(breakdown_started, breakdown_retained_1)

    update!(original_value: value)
  end

private

  def orchestrator
    Finance::ECF::CalculationOrchestrator.new(
      aggregator: Finance::ECF::ParticipantAggregator,
      contract: cpd_lead_provider.lead_provider.call_off_contract,
      statement: self,
    )
  end
end
