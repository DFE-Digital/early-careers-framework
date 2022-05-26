# frozen_string_literal: true

require_relative "../sections/base_section"

module Sections
  class CookieConsentBanner < Sections::BaseSection
    set_default_search_arguments ".govuk-cookie-banner", visible: false

    element :heading, "h2"
    element :success_message, :css, ".js-cookie-banner__success", visible: false

    load_validation do
      [has_heading?(text: "Cookies on Manage training for early career teachers"), "Cookie banner heading not found on page"]
    end

    def accept
      click_on "Accept analytics cookies"
    end

    def reject
      click_on "Reject analytics cookies"
    end

    def preferences_have_changed?
      element_visible? success_message
      element_has_content? success_message, "You’ve set your cookie preferences."
    end

    def change_preferences
      element_visible? success_message
      click_on "change your cookie settings"

      Pages::CookiePolicyPage.loaded
    end

    def hide_success_message
      click_on "Hide this message"
    end
  end
end
