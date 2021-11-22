# frozen_string_literal: true

module Finance
  module NPQ
    class CoursePaymentBreakdownsController < BaseController
      def show
        @npq_lead_provider = lead_provider_scope.find(params[:lead_provider_id])
        @npq_course        = NPQCourse.find_by!(identifier: params[:id])
        @breakdown         = Finance::NPQ::CalculationOrchestrator.call(
          aggregator: CurrentMilestoneParticipantDeclarationAggregator,
          calculator: PaymentCalculator::NPQ::PaymentCalculation,
          interval: Finance::Invoice.find_by_name("current").interval,
          npq_contract: @npq_lead_provider.npq_contracts.find_by!(course_identifier: params[:id]),
        )

        @cutoff_date = "On #{helpers.cutoff_date}"
      end

    private

      def lead_provider_scope
        policy_scope(NPQLeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
