# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class AdminSupportParticipantSchool < ::Pages::BasePage
    set_url "/admin/participants/{participant_id}/school"
    # this is a hack as the participants name is the page title
    set_primary_heading(/^.*$/)

    def has_school?(school_name)
      element_has_content? self, "School name", school_name
    end

    def has_lead_provider?(lead_provider_name)
      element_has_content? self, "Lead provider", lead_provider_name
    end
  end
end
