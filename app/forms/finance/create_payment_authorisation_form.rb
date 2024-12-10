# frozen_string_literal: true

module Finance
  class CreatePaymentAuthorisationForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Rails.application.routes.url_helpers

    attribute :statement
    attribute :checks_done, :boolean

    validates :checks_done, acceptance: { message: I18n.t("finance.statements.payment_authorisations.checks_done.error_message") }

    def save_form
      return false unless valid?

      Finance::Statements::MarkAsPaidJob.perform_later(statement_id: statement.id) if statement.mark_as_paid_at!
    end

    def back_link
      finance_ecf_payment_breakdown_statement_path(statement.lead_provider, statement)
    end
  end
end
