# frozen_string_literal: true

module Finance
  module ECF
    class PaymentBreakdownsController < BaseController
      def show
        @ecf_lead_provider = lead_provider_scope.find(params[:id])

        @breakdown = Finance::ECF::CalculationOrchestrator.call(
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
          contract: @ecf_lead_provider.call_off_contract,
          event_type: :started,
          calculator: Finance::ECF::ParticipantEligibleAggregator,
          aggregator: PaymentCalculator::ECF::PaymentCalculation,
        )
        @cutoff_date = "On #{helpers.cutoff_date}"
      end

    private

      def lead_provider_scope
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
