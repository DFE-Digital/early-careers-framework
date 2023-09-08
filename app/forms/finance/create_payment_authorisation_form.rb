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

      if statement.mark_as_paid!
        Finance::Statements::MarkAsPaidJob.perform_later(statement_id: statement.id)
      else
        false
      end

      true
    end

    def back_link
      if statement.ecf?
        finance_ecf_payment_breakdown_statement_path(statement.lead_provider, statement)
      elsif statement.npq?
        finance_npq_lead_provider_statement_path(statement.npq_lead_provider, statement)
      end
    end
  end
end
