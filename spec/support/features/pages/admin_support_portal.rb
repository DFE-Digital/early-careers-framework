# frozen_string_literal: true

module Pages
  class AdminSupportPortal
    include Capybara::DSL

    def view_participant_list
      click_on "Participants"

      Pages::AdminSupportParticipantList.new
    end
  end
end
