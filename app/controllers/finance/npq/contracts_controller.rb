# frozen_string_literal: true

module Finance
  module NPQ
    class ContractsController < BaseController
      def show
        @npq_lead_provider = lead_provider_scope.find(params[:id])
        @npq_contracts = @npq_lead_provider.npq_contracts
      end

    private

      def lead_provider_scope
        policy_scope(NPQLeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
