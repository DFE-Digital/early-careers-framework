# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class FinanceParticipantDrilldownSearch < ::Pages::BasePage
    set_url "/finance/participants"
    set_primary_heading "CPD contract data"

    def find(search_term)
      id = User.find_by(full_name: search_term)&.id
      id = search_term if id.blank?

      fill_in "Search records", with: id
      click_on "Search"

      Pages::FinanceParticipantDrilldown.loaded
    end
  end
end
