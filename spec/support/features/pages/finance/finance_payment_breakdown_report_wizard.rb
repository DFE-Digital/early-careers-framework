# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class FinancePaymentBreakdownReportWizard < ::Pages::BasePage
    set_url "/finance/payment-breakdowns/choose-provider-ecf"
    set_primary_heading "Choose provider"

    def complete(lead_provider_name)
      select_lead_provider lead_provider_name
    end

    def select_lead_provider(lead_provider_name)
      choose lead_provider_name
      click_on "Continue"

      Pages::FinancePaymentBreakdownReport.loaded
    end
  end
end
