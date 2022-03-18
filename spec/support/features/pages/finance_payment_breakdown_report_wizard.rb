# frozen_string_literal: true

module Pages
  class FinancePaymentBreakdownReportWizard
    include Capybara::DSL

    def complete(lead_provider_name)
      view_ecf_payments
      select_lead_provider lead_provider_name

      Pages::FinancePaymentBreakdownReport.new
    end

    def view_ecf_payments
      choose "ECF payments"
      click_on "Continue"
    end

    def select_lead_provider(lead_provider_name)
      choose lead_provider_name
      click_on "Continue"
    end
  end
end
