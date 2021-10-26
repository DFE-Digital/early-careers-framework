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
        )

        @payment_period = helpers.payment_period
        @cutoff_date = "On #{helpers.cutoff_date}"
      end

      def payable
        @ecf_lead_provider = lead_provider_scope.find(params[:id])

        @breakdown = CalculationOrchestrator.call(
          aggregator: ::ParticipantEventPayableAggregator,
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
          contract: @ecf_lead_provider.call_off_contract,
          event_type: :started,
        )

        @payment_period = helpers.payment_period_payable
        @cutoff_date = "On #{helpers.cutoff_date_payable}"

        render :show
      end

    private

      def lead_provider_scope
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
