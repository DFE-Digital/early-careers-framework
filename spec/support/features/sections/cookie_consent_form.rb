# frozen_string_literal: true

require_relative "./base_section"

module Sections
  class CookieConsentForm < ::Sections::BaseSection
    set_default_search_arguments "#new_cookies_form"

    element :legend, "fieldset > legend"
    element :on_field, "#cookies-form-analytics-consent-on-field", visible: false
    element :off_field, "#cookies-form-analytics-consent-off-field", visible: false

    def save_preference
      click_on "Save cookie settings"
    end

    def give_consent
      choose "Yes"
      save_preference

      Pages::CookiePolicyPage.loaded
    end

    def revoke_consent
      choose "No"
      save_preference

      Pages::CookiePolicyPage.loaded
    end
  end
end
