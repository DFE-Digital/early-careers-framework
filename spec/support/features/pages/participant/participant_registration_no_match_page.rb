# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class ParticipantRegistrationNoMatchPage < ::Pages::BasePage
    set_url "/participants/validation/no-match"
    set_primary_heading "We still cannot find your details"

    def continue
      click_on "Continue"
    end
  end
end
