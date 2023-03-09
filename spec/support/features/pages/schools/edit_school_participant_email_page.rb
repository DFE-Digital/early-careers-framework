# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class EditSchoolParticipantEmailPage < ::Pages::BasePage
    set_url "/schools/{slug}/participants/{participant_id}/edit-email"
    set_primary_heading(/\AWhat’s (.*)’s correct email address\?\z/)

    def confirm_the_participant(name:)
      element_has_content?(header, "What’s #{name}’s correct email address?")
    end

    def set_a_blank_email
      fill_in("email", with: "")
      click_on("Continue")
    end

    def set_an_invalid_email
      fill_in("email", with: "invalidemail")
      click_on("Continue")
    end

    def set_the_email(new_email:)
      fill_in("email", with: new_email)
      click_on("Continue")

      Pages::SchoolParticipantEmailUpdatedPage.loaded
    end
  end
end
