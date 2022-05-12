# frozen_string_literal: true

require_relative "./base_page"
require_relative "../sections/cookie_consent_form"

module Pages
  class CookiePolicyPage < ::Pages::BasePage
    set_url "/cookies"
    set_primary_heading "Cookies"

    section :cookie_consent_form, ::Sections::CookieConsentForm

    def confirm_cookie_consent_is_not_given
      !cookie_consent_form.on_field.checked? && cookie_consent_form.off_field.checked?
    end

    def confirm_cookie_consent_is_given
      cookie_consent_form.on_field.checked? && !cookie_consent_form.off_field.checked?
    end

    def give_cookie_consent
      cookie_consent_form.give_consent
    end

    def revoke_cookie_consent
      cookie_consent_form.revoke_consent
    end
  end
end
