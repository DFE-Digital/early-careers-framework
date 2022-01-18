# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module NPQ
    class StatementsController < BaseController
      def show
        @statement         = Finance::Statement::NPQ.find_by_name(params[:id])
        @npq_lead_provider = lead_provider_scope.find(params[:lead_provider_id])
        @breakdowns        = Finance::NPQ::CalculationOverviewOrchestrator.call(
          cpd_lead_provider: @npq_lead_provider.cpd_lead_provider,
          event_type: :started,
          interval: @statement.interval,
        )
      end

    private

      def lead_provider_scope
        policy_scope(NPQLeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
