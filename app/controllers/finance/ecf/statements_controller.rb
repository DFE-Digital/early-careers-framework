# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module ECF
    class StatementsController < BaseController
      def show
        @ecf_lead_provider = lead_provider_scope.find(params[:payment_breakdown_id])
        @statement = @ecf_lead_provider.statements.find_by(name: identifier_to_name)
        @calculator = StatementCalculator.new(statement: @statement)
      end

      def show2
        @ecf_lead_provider = lead_provider_scope.find(params[:payment_breakdown_id])
        statement_name = params[:statement_id].humanize.gsub("-", " ")
        @statement = @ecf_lead_provider.statements.find_by(name: statement_name)
        @calculator = StatementCalculator2.new(statement: @statement)

        render :show
      end

    private

      def identifier_to_name
        params[:id].humanize.gsub("-", " ")
      end

      def lead_provider_scope
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
