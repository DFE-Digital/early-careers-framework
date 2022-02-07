# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module ECF
    class StatementsController < BaseController
      def show
        @ecf_lead_provider = lead_provider_scope.find(params[:payment_breakdown_id])
        @cpd_lead_provider = @ecf_lead_provider.cpd_lead_provider

        @statements = @ecf_lead_provider.statements.upto_current.order(payment_date: :desc)

        @statement = @ecf_lead_provider.statements.find(params[:id])

        aggregator = ParticipantAggregator.new(
          statement: @statement,
          recorder: ParticipantDeclaration::ECF.where.not(state: %w[voided]),
        )

        orchestrator = Finance::ECF::CalculationOrchestrator.new(
          aggregator: aggregator,
          contract: @ecf_lead_provider.call_off_contract,
          statement: @statement,
        )

        @breakdown_started = orchestrator.call(event_type: :started)
        @breakdown_retained_1 = orchestrator.call(event_type: :retained_1)
      end

    private

      def lead_provider_scope
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
