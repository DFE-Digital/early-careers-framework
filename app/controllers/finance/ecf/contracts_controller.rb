# frozen_string_literal: true

module Finance
  module ECF
    class ContractsController < BaseController
      def show
        @ecf_lead_provider = lead_provider_scope.find(params[:id])
        # TODO: back link goes to latest statement rather that where they were
        @latest_statement = Statement::ECF
          .where(cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider)
          .order(deadline_date: :desc)
          .first
        @contract = @ecf_lead_provider.call_off_contract
      end

    private

      def lead_provider_scope
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
