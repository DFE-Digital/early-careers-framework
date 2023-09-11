# frozen_string_literal: true

module Finance
  module ECF
    class StatementsController < BaseController
      def show
        @ecf_lead_provider = lead_provider_scope.find(params[:payment_breakdown_id])
        @statement = @ecf_lead_provider.statements.find(params[:id])
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
        policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
