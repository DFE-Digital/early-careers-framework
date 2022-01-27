# frozen_string_literal: true

module Finance
  module ECF
    class PaymentBreakdownsController < BaseController
      def show
        @ecf_lead_provider = lead_provider_scope.find(params[:id])

        @statement = Finance::Statement::ECF.find_by(
          name: "November 2021",
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
        )

        @breakdown = Finance::ECF::CalculationOrchestrator.call(
          aggregator: eligible_aggregator,
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
          contract: @ecf_lead_provider.call_off_contract,
          event_type: :started,
        )
      end

      def payable
        @ecf_lead_provider = lead_provider_scope.find(params[:id])

        @statement = Finance::Statement::ECF.find_by(
          name: "January 2022",
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
        )

        @breakdown = Finance::ECF::CalculationOrchestrator.call(
          aggregator: payable_aggregator,
          cpd_lead_provider: @ecf_lead_provider.cpd_lead_provider,
          contract: @ecf_lead_provider.call_off_contract,
          event_type: :started,
        )

        render :show
      end

    private

      def payable_aggregator
        statement = @statement
        Class.new(ParticipantPayableAggregator) do
          define_singleton_method(:call) do |cpd_lead_provider:, interval:, recorder: ParticipantDeclaration::ECF.where(statement: statement), event_type: :started|
            new(cpd_lead_provider: cpd_lead_provider, recorder: recorder).call(event_type: event_type, interval: interval)
          end
        end
      end

      def eligible_aggregator
        statement = @statement
        Class.new(ParticipantEligibleAggregator) do
          define_singleton_method(:call) do |cpd_lead_provider:, interval:, recorder: ParticipantDeclaration::ECF.where(statement: statement), event_type: :started|
            new(cpd_lead_provider: cpd_lead_provider, recorder: recorder).call(event_type: event_type, interval: interval)
          end
        end
      end

      def lead_provider_scope
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
