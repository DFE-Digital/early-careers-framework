# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class FinancePortal < ::Pages::BasePage
    set_url "/finance/manage-cpd-contracts"
    set_primary_heading "Manage CPD contracts"

    def view_payment_breakdown
      click_on "Payment Breakdown"

      Pages::FinancePaymentBreakdownReportWizard.loaded
    end

    def view_schedules
      click_on "Schedules"

      full_stop
    end

    def view_participant_drilldown
      click_on "Participant drilldown"

      Pages::FinanceParticipantDrilldownSearch.loaded
    end
  end
end
