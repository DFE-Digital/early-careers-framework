# frozen_string_literal: true

class Finance::Statement::ECF < Finance::Statement
  has_one :lead_provider, through: :cpd_lead_provider

  def contract
    CallOffContract.find_by!(
      version: contract_version,
      cohort:,
      lead_provider:,
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
      aggregator:,
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

  def total_payment_combined(breakdown_started, breakdown_retained_1)
    service_fee = breakdown_started[:service_fees].map { |params| params[:monthly] }.sum
    output_payment = breakdown_started[:output_payments].map { |params| params[:subtotal] }.sum
    other_fees = breakdown_started[:other_fees].values.map { |other_fee| other_fee[:subtotal] }.sum
    retained_output_payment = breakdown_retained_1[:output_payments].map { |params| params[:subtotal] }.sum

    service_fee + output_payment + other_fees + retained_output_payment
  end
end

require "finance/statement/ecf/payable"
require "finance/statement/ecf/paid"
