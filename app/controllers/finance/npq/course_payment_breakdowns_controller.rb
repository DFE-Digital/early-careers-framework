# frozen_string_literal: true

module Finance
  module NPQ
    class CoursePaymentBreakdownsController < BaseController
      def show
        @statement         = Finance::Statement::NPQ.find_by_name(params[:statement_id])
        @npq_lead_provider = lead_provider_scope.find(params[:lead_provider_id])
        @npq_course        = NPQCourse.find_by!(identifier: params[:id])
        @breakdown         = Finance::NPQ::CalculationOrchestrator.call(
          cpd_lead_provider: @npq_lead_provider.cpd_lead_provider,
          contract: @npq_lead_provider.npq_contracts.find_by!(course_identifier: params[:id]),
        )
      end

    private

      def lead_provider_scope
        policy_scope(NPQLeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
