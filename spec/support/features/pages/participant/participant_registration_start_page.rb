# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class ParticipantRegistrationStartPage < ::Pages::BasePage
    set_url "/participants/start-registration"
    set_primary_heading "Register for DfE funding for ECF-based training and mentoring"

    def continue
      click_on "Continue"

      Pages::SignInPage.loaded
    end
  end
end
