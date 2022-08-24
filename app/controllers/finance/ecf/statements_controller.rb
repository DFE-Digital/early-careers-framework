# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module ECF
    class StatementsController < BaseController
      def show
        @ecf_lead_provider = lead_provider_scope.find(params[:payment_breakdown_id])
        @statement = @ecf_lead_provider.statements.find(params[:id])
        @calculator = StatementCalculator.new(statement: @statement)
      end

    private

      def lead_provider_scope
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
