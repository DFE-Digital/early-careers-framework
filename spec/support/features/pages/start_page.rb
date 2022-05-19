# frozen_string_literal: true

require_relative "./base"

module Pages
  class StartPage < ::Pages::Base
    set_url "/"
    set_primary_heading "Manage training for early career teachers"

    element :start_now_button, "a.govuk-button--start", text: "Start now"

    def start_now
      click_on "Start now"

      Pages::SignInPage.new
    end

    def view_accessibility_statement
      click_on "Accessibility"

      Pages::AccessibilityStatementPage.new
    end

    def view_privacy_policy
      click_on "Privacy"

      Pages::PrivacyPolicyPage.new
    end
  end
end
