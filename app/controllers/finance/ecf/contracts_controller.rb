# frozen_string_literal: true

module Finance
  module ECF
    class ContractsController < BaseController
      def index
        @ecf_lead_providers = LeadProvider.all
      end

      def show
        @ecf_lead_provider = lead_provider_scope.find(params[:id])
        @contract = @ecf_lead_provider.call_off_contract
      end

    private

      def lead_provider_scope
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
