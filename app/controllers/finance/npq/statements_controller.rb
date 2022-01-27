# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module NPQ
    class StatementsController < BaseController
      def show
        @npq_lead_provider = lead_provider_scope.find(params[:lead_provider_id])
        @cpd_lead_provider = @npq_lead_provider.cpd_lead_provider

        @statement = Finance::Statement::NPQ.find_by(
          name: params[:id],
          cpd_lead_provider: @cpd_lead_provider,
        )

        @breakdowns = Finance::NPQ::CalculationOverviewOrchestrator.call(
          cpd_lead_provider: @cpd_lead_provider,
          event_type: :started,
          aggregator: aggregator_with_statement(statement: @statement),
        )
      end

    private

      def aggregator_with_statement(statement:)
        Class.new(Finance::NPQ::ParticipantEligibleAndPayableAggregator) do
          define_singleton_method(:call) do |cpd_lead_provider: nil, interval: nil, recorder: ParticipantDeclaration::NPQ.where(statement: statement), event_type: :started, course_identifier: nil|
            new(cpd_lead_provider: cpd_lead_provider, recorder: recorder, course_identifier: course_identifier)
              .call(event_type: event_type, interval: interval)
          end
        end
      end

      def lead_provider_scope
        policy_scope(NPQLeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
