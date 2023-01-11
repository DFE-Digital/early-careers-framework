# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class AdminSupportParticipantList < ::Pages::BasePage
    set_url "/admin/participants"
    # this is a hack as the participants name is the page title
    set_primary_heading(/^.*$/)

    def view_participant(participant_name)
      click_on participant_name

      Pages::AdminSupportParticipantDetail.loaded
    end
  end
end
