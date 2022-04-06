# frozen_string_literal: true

module Pages
  class FinancePortal
    include Capybara::DSL

    def view_participant_drilldown
      click_on "Participant drilldown"

      Pages::FinanceParticipantDrilldownSearch.new
    end

    def view_payment_breakdown
      click_on "Payment Breakdown"

      Pages::FinancePaymentBreakdownReportWizard.new
    end
  end
end
