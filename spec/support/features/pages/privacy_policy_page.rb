# frozen_string_literal: true

require_relative "./base_page"

module Pages
  class PrivacyPolicyPage < ::Pages::BasePage
    set_url "/privacy-policy"
    set_primary_heading "Privacy policy"

    def continue_for_ect
      click_on "Continue"

      Pages::EctRegistrationWizard.loaded
    end

    def continue_for_mentor
      click_on "Continue"

      Pages::MentorRegistrationWizard.loaded
    end
  end
end
