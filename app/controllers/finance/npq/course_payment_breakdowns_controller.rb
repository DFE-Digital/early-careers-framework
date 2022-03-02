# frozen_string_literal: true

module Finance
  module NPQ
    class CoursePaymentBreakdownsController < BaseController
      def show
        @npq_lead_provider = lead_provider_scope.find(params[:lead_provider_id])
        @cpd_lead_provider = @npq_lead_provider.cpd_lead_provider
        @npq_course        = NPQCourse.find_by!(identifier: params[:id])
        @statement         = @cpd_lead_provider.npq_lead_provider.statements.find_by(name: statement_id_to_name)
        @breakdown         = Finance::NPQ::CalculationOrchestrator.new(
          statement: @statement,
          contract: @npq_lead_provider.npq_contracts.find_by!(course_identifier: params[:id]),
          aggregator: aggregator,
        ).call(event_type: :started)
      end

    private

      def statement_id_to_name
        params[:statement_id].humanize.gsub("-", " ")
      end

      def lead_provider_scope
        policy_scope(NPQLeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end

      def aggregator
        if @statement.past_deadline_date?
          Finance::NPQ::ParticipantEligibleAndPayableAggregator.new(
            statement: @statement,
            recorder: ParticipantDeclaration::NPQ.where.not(state: %w[voided]),
            course_identifier: params[:id],
          )
        else
          ParticipantAggregator.new(
            statement: @statement,
            recorder: ParticipantDeclaration::NPQ.where.not(state: %w[voided]),
            course_identifier: params[:id],
          )
        end
      end
    end
  end
end
