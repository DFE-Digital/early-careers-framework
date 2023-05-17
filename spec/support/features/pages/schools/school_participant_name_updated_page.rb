# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantNameUpdatedPage < ::Pages::BasePage
    set_url "/schools/{slug}/participants/{participant_id}/update-name"
    set_primary_heading(/\A(.*)’s name has been edited to (.*)\z/)

    def see_a_confirmation_message(old_name:, new_name:)
      element_has_content?(header, "#{old_name}’s name has been edited to #{new_name}")
    end

    def return_to_the_participant_profile
      click_on "Return to their details"

      Pages::SchoolParticipantDetailsPage.loaded
    end

    def return_to_the_ect_and_mentors
      click_on("Return to manage mentors and ECTs")

      Pages::SchoolParticipantsDashboardPage.loaded
    end
  end
end
