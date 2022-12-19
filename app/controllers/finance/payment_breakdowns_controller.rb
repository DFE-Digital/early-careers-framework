# frozen_string_literal: true

module Finance
  class PaymentBreakdownsController < BaseController
    before_action :set_programme_form

    def show
      redirect_to action: :select_programme
    end

    def select_programme; end

    def choose_programme
      render "select_programme" and return unless @choose_programme_form.valid?(:choose_programme)

      if @choose_programme_form.programme == "ecf"
        redirect_to action: :select_provider_ecf
      else
        redirect_to action: :select_provider_npq
      end
    end

    def select_provider_ecf; end

    def choose_provider_ecf
      render "select_provider_ecf" and return unless @choose_programme_form.valid?(:choose_provider)

      lead_provider = LeadProvider.find(@choose_programme_form.provider)

      redirect_to finance_ecf_payment_breakdown_statement_path(lead_provider, (lead_provider.statements.current || lead_provider.statements.latest))
    end

    def select_provider_npq; end

    def choose_provider_npq
      render "select_provider_npq" and return unless @choose_programme_form.valid?(:choose_provider)

      npq_lead_provider = NPQLeadProvider.find(@choose_programme_form.provider)

      statement = npq_lead_provider.statements.current

      # TODO: remove when we have created the next statement
      statement ||= npq_lead_provider.statements.order(payment_date: :desc).first

      redirect_to finance_npq_lead_provider_statement_path(npq_lead_provider, statement)
    end

    def choose_npq_statement
      cohort = Cohort[params[:cohort_year]]
      npq_lead_provider = NPQLeadProvider.find(params[:npq_lead_provider])
      statement_name = params[:statement].humanize.gsub("-", " ")
      statement = npq_lead_provider.statements.find_by(cohort:, name: statement_name)

      redirect_to finance_npq_lead_provider_statement_path(npq_lead_provider.id, statement)
    end

    def choose_ecf_statement
      cohort = Cohort[params[:cohort_year]]
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
