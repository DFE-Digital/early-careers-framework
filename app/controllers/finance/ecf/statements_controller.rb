# frozen_string_literal: true

module Finance
  module ECF
    class StatementsController < BaseController
      include RelaxedContentSecurityPolicy

      def show
        @ecf_lead_provider = lead_provider_scope.find(params[:payment_breakdown_id])
        @statement = @ecf_lead_provider.statements.find(params[:id])
        @mentor_funding_cohort = @statement.cohort.mentor_funding?
        @cohorts = Cohort.where(start_year: 2021..).ordered_by_start_year

        if @mentor_funding_cohort
          @mentor_calculator = Mentor::StatementCalculator.new(statement: @statement)
          @ect_calculator = ECT::StatementCalculator.new(statement: @statement)
        else
          @calculator = StatementCalculator.new(statement: @statement)
        end

        set_important_message(title: t("finance.statements.payment_authorisations.banner.title"), content: t("finance.statements.payment_authorisations.banner.content", statement_marked_as_paid_at: @statement.marked_as_paid_at.strftime("%-I:%M%P on %-e %b %Y"))) if authorising_for_payment_banner_visible?(@statement)
      end

    private

      def lead_provider_scope
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
