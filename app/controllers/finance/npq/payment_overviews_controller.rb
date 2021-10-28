# frozen_string_literal: true

module Finance
  module NPQ
    class PaymentOverviewsController < BaseController
      def show
        @npq_lead_provider = lead_provider_scope.find(params[:id])

        @breakdowns = Finance::NPQ::CalculationOverviewOrchestrator.call(
          cpd_lead_provider: @npq_lead_provider.cpd_lead_provider,
          event_type: :started,
        )
      end

    private

      def lead_provider_scope
        policy_scope(NPQLeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
