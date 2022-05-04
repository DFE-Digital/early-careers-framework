# frozen_string_literal: true

require_relative "../base"

module Pages
  class FinancePortal < ::Pages::Base
    set_url "/finance/manage-cpd-contracts"
    set_primary_heading "Manage CPD contracts"

    def view_participant_drilldown
      click_on "Participant drilldown"

      Pages::FinanceParticipantDrilldownSearch.loaded
    end

    def view_payment_breakdown
      click_on "Payment Breakdown"

      Pages::FinancePaymentBreakdownReportWizard.loaded
    end
  end
end
