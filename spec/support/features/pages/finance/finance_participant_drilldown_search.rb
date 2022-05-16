# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class FinanceParticipantDrilldownSearch < ::Pages::BasePage
    set_url "/finance/participants"
    set_primary_heading "CPD contract data"

    def find(participant_name)
      user = User.find_by(full_name: participant_name)

      fill_in "Search records", with: user.id
      click_on "Search"

      Pages::FinanceParticipantDrilldown.loaded
    end
  end
end
