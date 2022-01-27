# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module NPQ
    class StatementsController < BaseController
      def show
        @statement         = temporary_statements.find { |statement| statement.name == params[:id] }
        @npq_lead_provider = lead_provider_scope.find(params[:lead_provider_id])
        @breakdowns        = Finance::NPQ::CalculationOverviewOrchestrator.call(
          cpd_lead_provider: @npq_lead_provider.cpd_lead_provider,
          event_type: :started,
        )
      end

    private

      def lead_provider_scope
        policy_scope(NPQLeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end

      helper_method :temporary_statements
      def temporary_statements
        [
          { name: "December 2021", deadline_date: Date.new(2021, 12, 25), payment_date: Date.new(2022, 1, 31) },
          { name: "January 2022", deadline_date: Date.new(2022, 1, 31), payment_date: Date.new(2022, 2, 28) },
        ].map { |hash| Finance::Statement::NPQ.new(hash) }
      end
    end
  end
end
