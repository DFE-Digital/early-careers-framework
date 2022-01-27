# frozen_string_literal: true

module Finance
  module NPQ
    class CoursePaymentBreakdownsController < BaseController
      def show
        @npq_lead_provider = lead_provider_scope.find(params[:lead_provider_id])
        @cpd_lead_provider = @npq_lead_provider.cpd_lead_provider

        @statement = Finance::Statement::NPQ.find_by(
          name: params[:statement_id],
          cpd_lead_provider: @cpd_lead_provider,
        )

        if @statement.name == "January 2022"
          @statement.id = nil
        end

        @npq_course        = NPQCourse.find_by!(identifier: params[:id])
        @breakdown         = Finance::NPQ::CalculationOrchestrator.new(
          statement: @statement,
          contract: @npq_lead_provider.npq_contracts.find_by!(course_identifier: params[:id]),
        ).call(event_type: :started)
      end

    private


      def lead_provider_scope
        policy_scope(NPQLeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
