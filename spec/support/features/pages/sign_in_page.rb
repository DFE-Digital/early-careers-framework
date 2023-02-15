# frozen_string_literal: true

require_relative "./base_page"

module Pages
  class SignInCompletePage < ::Pages::BasePage
    set_url "/users/confirm_sign_in{?login_token}"
    set_primary_heading "You’re now signed in"

    def continue
      click_on "Continue"

      # Pages::ParticipantPrivacyPolicyPage.loaded
    end
  end

  class SignInPage < ::Pages::BasePage
    set_url "/users/sign_in"
    set_primary_heading "Sign in"

    def add_email_address(email_address)
      fill_in "Email address", with: email_address
      click_on "Sign in"

      user = User.find_by(email: email_address)

      Pages::SignInCompletePage.load login_token: user.login_token
    end
  end
end
