# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class AdminSupportPortal < ::Pages::BasePage
    set_url "/admin"
    set_primary_heading "Overview"

    def view_participant_list
      click_on "Participants"

      Pages::AdminSupportParticipantList.loaded
    end
  end
end
