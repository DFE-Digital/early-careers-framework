# frozen_string_literal: true

module Finance
  class PaymentBreakdownsController < BaseController
    before_action :set_programme_form

    def show
      redirect_to finance_path
    end

    def select_provider_ecf; end

    def choose_provider_ecf
      unless @choose_programme_form.valid?(:choose_provider)
        track_validation_error(@choose_programme_form)
        render "select_provider_ecf"
        return
      end

      lead_provider = LeadProvider.find(@choose_programme_form.provider)

      redirect_to finance_ecf_payment_breakdown_statement_path(lead_provider, (lead_provider.statements.current || lead_provider.statements.latest))
    end

    def choose_ecf_statement
      cohort = Cohort.find_by(start_year: params[:cohort_year])
      lead_provider = LeadProvider.find(params[:lead_provider])
      statement_name = params[:statement].humanize.gsub("-", " ")
      statement = lead_provider.statements.find_by(cohort:, name: statement_name)

      redirect_to finance_ecf_payment_breakdown_statement_path(lead_provider.id, statement)
    end

  private

    def set_programme_form
      @choose_programme_form = Finance::ChoosePaymentBreakdownForm.new(programme_form_params)
    end

    def programme_form_params
      return {} unless params.key?(:finance_choose_payment_breakdown_form)

      params.require(:finance_choose_payment_breakdown_form).permit(:programme, :provider)
    end
  end
end
