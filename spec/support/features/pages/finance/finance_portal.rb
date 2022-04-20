# frozen_string_literal: true

require_relative "../base"

module Pages
  class FinancePortal < ::Pages::Base
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
