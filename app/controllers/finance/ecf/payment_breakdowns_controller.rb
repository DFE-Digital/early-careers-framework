# frozen_string_literal: true

module Finance
  module ECF
    class PaymentBreakdownsController < BaseController
      def show
        @ecf_lead_provider = lead_provider_scope.find(params[:id])

        @breakdown = Finance::ECF::CalculationOrchestrator.call(
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
          contract: @ecf_lead_provider.call_off_contract,
          event_type: :started,
        )

        @payment_date = current_payment_date
        @deadline_date = current_deadline_date
      end

      def payable
        @ecf_lead_provider = lead_provider_scope.find(params[:id])

        @breakdown = CalculationOrchestrator.call(
          aggregator: ParticipantPayableAggregator,
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
          contract: @ecf_lead_provider.call_off_contract,
          event_type: :started,
        )

        @payment_date = payable_payment_date
        @deadline_date = payable_deadline_date

        render :show
      end

    private

      def lead_provider_scope
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end

      def payable_milestone
        Finance::Milestone
          .joins(:schedule)
          .where(schedule: { type: "Finance::Schedule::ECF" })
          .order(payment_date: :asc)
          .find { |milestone| milestone.payment_date >= Time.zone.today }
      end

      def payable_payment_date
        payable_milestone.payment_date
      end

      def payable_deadline_date
        payable_milestone.milestone_date
      end

      def current_milestone
        Finance::Milestone
          .joins(:schedule)
          .where(schedule: { type: "Finance::Schedule::ECF" })
          .order(payment_date: :asc)
          .find { |milestone| milestone.milestone_date >= Time.zone.today }
      end

      def current_payment_date
        current_milestone.payment_date
      end

      def current_deadline_date
        current_milestone.milestone_date
      end
    end
  end
end
