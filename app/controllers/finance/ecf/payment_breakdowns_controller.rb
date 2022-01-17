# frozen_string_literal: true

module Finance
  module ECF
    class PaymentBreakdownsController < BaseController
      def show
        @ecf_lead_provider = lead_provider_scope.find(params[:id])

        @invoice = Finance::Invoice::ECF.find_by_name("current")

        @breakdown = Finance::ECF::CalculationOrchestrator.call(
          aggregator: ParticipantEligibleAggregator,
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
          contract: @ecf_lead_provider.call_off_contract,
          event_type: :started,
          interval: @invoice.interval,
        )
      end

      def payable
        @ecf_lead_provider = lead_provider_scope.find(params[:id])

        @invoice = Finance::Invoice::ECF.find_by_name("payable")

        @breakdown = Finance::ECF::CalculationOrchestrator.call(
          aggregator: ParticipantPayableAggregator,
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
          contract: @ecf_lead_provider.call_off_contract,
          event_type: :started,
          interval: @invoice.interval,
        )

        render :show
      end

    private

      def lead_provider_scope
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
