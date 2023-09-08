# frozen_string_literal: true

module Finance
  class PaymentAuthorisationsController < BaseController
    before_action :set_statement
    before_action :set_payment_authorisation_form

    def new; end

    def create
      if @payment_authorisation_form.save_form
        set_important_message(title: "Authorising for payment", content: "Requested at #{@statement.marked_as_paid_at.strftime('%-I:%M%P on %-e %b %Y')}. We'll email you when the payment has been authorised and the statement updated. This may take up to 15 minutes.")
        redirect_to @payment_authorisation_form.back_link
      else
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
