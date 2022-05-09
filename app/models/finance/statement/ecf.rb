# frozen_string_literal: true

class Finance::Statement::ECF < Finance::Statement
  has_one :lead_provider, through: :cpd_lead_provider
  has_many :participant_declarations,        -> { not_voided.not_ineligible }, foreign_key: :statement_id
  has_many :voided_participant_declarations, -> { voided }, foreign_key: :statement_id, class_name: "ParticipantDeclaration::ECF"

  def contract
    CallOffContract.find_by!(
      version: contract_version,
      cohort: cohort,
      lead_provider: lead_provider,
    )
  end

  def cache_original_value!
    breakdown_started = orchestrator.call(event_type: :started)
    breakdown_retained_1 = orchestrator.call(event_type: :retained_1)
    value = total_payment_combined(breakdown_started, breakdown_retained_1)

    update!(original_value: value)
  end

  def payable!
    update!(type: "Finance::Statement::ECF::Payable")
  end

private

  def orchestrator
    Finance::ECF::CalculationOrchestrator.new(
      aggregator: aggregator,
      contract: cpd_lead_provider.lead_provider.call_off_contract,
      statement: self,
    )
  end

  def aggregator
    Finance::ECF::ParticipantAggregator.new(
      statement: self,
      recorder: ParticipantDeclaration::ECF.where.not(state: %w[voided]),
    )
  end
end

require "finance/statement/ecf/payable"
require "finance/statement/ecf/paid"
