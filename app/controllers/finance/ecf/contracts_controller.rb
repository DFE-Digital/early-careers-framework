# frozen_string_literal: true

module Finance
  module ECF
    class ContractsController < BaseController
      def show
        latest_statement
        @contract = ecf_lead_provider.call_off_contract
      end

    private

      def lead_provider_scope
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end

      def latest_statement
        @latest_statement ||= \
          ecf_lead_provider.statements.payable.first || \
          ecf_lead_provider.statements.order(:payment_date).last
      end

      def ecf_lead_provider
        @ecf_lead_provider ||= lead_provider_scope.find(params[:id])
      end
    end
  end
end
