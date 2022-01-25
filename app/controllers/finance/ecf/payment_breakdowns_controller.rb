# frozen_string_literal: true

module Finance
  module ECF
    class PaymentBreakdownsController < BaseController
      def show
        @ecf_lead_provider = lead_provider_scope.find(params[:id])

        @statement = Finance::Statement::ECF.new(
          name: "November 2021",
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
          deadline_date: Date.new(2021, 11, 30),
          payment_date: Date.new(2021, 11, 30),
        )

        @breakdown = Finance::ECF::CalculationOrchestrator.call(
          aggregator: ParticipantEligibleAggregator,
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
          contract: @ecf_lead_provider.call_off_contract,
          event_type: :started,
        )
      end

      def payable
        @ecf_lead_provider = lead_provider_scope.find(params[:id])

        @statement = Finance::Statement::ECF.new(
          name: "January 2022",
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
          deadline_date: Date.new(2022, 1, 31),
          payment_date: Date.new(2022, 2, 28),
        )

        @breakdown = Finance::ECF::CalculationOrchestrator.call(
          aggregator: ParticipantPayableAggregator,
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
          contract: @ecf_lead_provider.call_off_contract,
          event_type: :started,
        )

        render :show
      end

    private

      def lead_provider_scope
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
