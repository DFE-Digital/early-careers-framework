# frozen_string_literal: true

module Pages
  class FinancePortal
    include Capybara::DSL

    def view_participant_drilldown
      click_on "Participant drilldown"

      Pages::FinanceParticipantDrilldownSearch.new
    end
  end
end
