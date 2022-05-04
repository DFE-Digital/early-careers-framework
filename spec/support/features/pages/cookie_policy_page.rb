# frozen_string_literal: true

require_relative "./base"

module Sections
  class CookieConsentForm < SitePrism::Section
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

    def consent_given?
      on_field.checked? && !off_field.checked?
    end

    def consent_not_given?
      !on_field.checked? && off_field.checked?
    end

    def preferences_have_changed?
      has_content? "You’ve set your cookie preferences."
    end
  end
end

module Pages
  class CookiePolicyPage < ::Pages::Base
    set_url "/cookies"
    set_primary_heading "Cookies"

    section :cookie_consent_form, ::Sections::CookieConsentForm
  end
end
