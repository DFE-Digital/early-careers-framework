# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class ParticipantPrivacyPolicyPage < ::Pages::BasePage
    set_url "/privacy-policy"
    set_primary_heading "Privacy policy"

    def continue
      click_on "Continue"

      Pages::ParticipantRegistrationWizard.loaded
    end
  end
end
