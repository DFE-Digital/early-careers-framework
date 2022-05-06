# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class AdminSupportParticipantList < ::Pages::BasePage
    set_url "/admin/participants"
    set_primary_heading "Participants"

    def view_participant(participant_name)
      click_on participant_name

      Pages::AdminSupportParticipantDetail.loaded
    end
  end
end
