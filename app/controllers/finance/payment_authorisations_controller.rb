# frozen_string_literal: true

module Finance
  class PaymentAuthorisationsController < BaseController
    before_action :set_statement
    before_action :set_payment_authorisation_form

    def new; end

    def create
      if @payment_authorisation_form.save_form
        redirect_to @payment_authorisation_form.back_link
      else
        track_validation_error(@payment_authorisation_form)
        render :new, status: :unprocessable_entity
      end
    end

  private

    def set_payment_authorisation_form
      @payment_authorisation_form = Finance::CreatePaymentAuthorisationForm.new(finance_payment_authorisation_form_params.merge(statement: @statement))
    end

    def finance_payment_authorisation_form_params
      return {} unless params.key?(:finance_payment_authorisation)

      params.require(:finance_payment_authorisation).permit(:checks_done)
    end

    def set_statement
      @statement = Finance::Statement.find(params[:statement_id])
    end
  end
end
