# frozen_string_literal: true

module Finance
  module NPQ
    class StatementsController < BaseController
      def show
        @npq_lead_provider = lead_provider_scope.find(params[:lead_provider_id])
        @cpd_lead_provider = @npq_lead_provider.cpd_lead_provider
        @statement         = @cpd_lead_provider.npq_lead_provider.statements.find(params[:id])
        @statements        = @npq_lead_provider.statements.upto_current.order(payment_date: :desc)
        @npq_contracts     = @npq_lead_provider.npq_contracts.where(
          version: @statement.contract_version,
          cohort: @statement.cohort,
        ).order(course_identifier: :asc)
        @calculator = StatementCalculator.new(statement: @statement)
        set_important_message(title: t("finance.statements.payment_authorisations.banner.title"), content: t("finance.statements.payment_authorisations.banner.content", statement_marked_as_paid_at: @statement.marked_as_paid_at.strftime("%-I:%M%P on %-e %b %Y"))) if authorising_for_payment_banner_visible?(@statement)
      end

    private

      def lead_provider_scope
        policy_scope(NPQLeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
