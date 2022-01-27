# frozen_string_literal: true

module Finance
  module ECF
    class PaymentBreakdownsController < BaseController
      def show
        @ecf_lead_provider = lead_provider_scope.find(params[:id])

        @statement = Finance::Statement::ECF.find_by(
          name: "January 2022",
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
        )
        @statement.id = nil

        orchestrator = Finance::ECF::CalculationOrchestrator.new(
          aggregator: ParticipantEligibleAggregator,
          contract: @ecf_lead_provider.call_off_contract,
          statement: @statement,
        )

        @breakdown_started = orchestrator.call(event_type: :started)
        @breakdown_retained_1 = orchestrator.call(event_type: :retained_1)
      end

      def payable
        @ecf_lead_provider = lead_provider_scope.find(params[:id])

        @statement = Finance::Statement::ECF.find_by(
          name: "November 2021",
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
        )

        orchestrator = Finance::ECF::CalculationOrchestrator.new(
          aggregator: ParticipantPayableAggregator,
          contract: @ecf_lead_provider.call_off_contract,
          statement: @statement,
        )

        @breakdown_started = orchestrator.call(event_type: :started)
        @breakdown_retained_1 = orchestrator.call(event_type: :retained_1)

        render :show
      end

    private

      def lead_provider_scope
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
