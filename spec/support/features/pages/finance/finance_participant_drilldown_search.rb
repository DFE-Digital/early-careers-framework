# frozen_string_literal: true

require_relative "../base"

module Pages
  class FinanceParticipantDrilldownSearch < ::Pages::Base
    include Capybara::DSL

    def find(participant_name)
      user = User.find_by(full_name: participant_name)

      fill_in "Search participants", with: user.id
      click_on "Search"

      Pages::FinanceParticipantDrilldown.new
    end
  end
end
