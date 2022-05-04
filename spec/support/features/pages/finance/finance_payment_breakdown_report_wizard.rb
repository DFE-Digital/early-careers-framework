# frozen_string_literal: true

require_relative "../base"

module Pages
  class FinancePaymentBreakdownReportWizard < ::Pages::Base
    set_url "/finance/payment-breakdowns/choose-programme"
    set_primary_heading "Choose trainee payments scheme"

    def complete(lead_provider_name)
      view_ecf_payments
      select_lead_provider lead_provider_name
    end

    def view_ecf_payments
      choose "ECF payments"
      click_on "Continue"

      # FinancePaymentBreakdownsChooseEcfProviderWizard
      # /finance/payment-breakdowns/choose-provider-ecf
    end

    def select_lead_provider(lead_provider_name)
      choose lead_provider_name
      click_on "Continue"

      Pages::FinancePaymentBreakdownReport.loaded
    end
  end
end
