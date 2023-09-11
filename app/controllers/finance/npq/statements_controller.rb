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

        respond_to do |format|
          format.html
          format.pdf do
            html_string = render_to_string(action: :show, formats: :html)
            pdf = Grover.new(
              html_string,
              display_url: root_url,
              format: "A4",
              emulate_media: "screen",
            ).to_pdf
            send_data(pdf, disposition: "attachment", filename: "statement_#{params[:id]}.pdf", type: "application/pdf")
          end
        end
      end

    private

      def lead_provider_scope
        policy_scope(NPQLeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
