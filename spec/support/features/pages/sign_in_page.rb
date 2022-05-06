# frozen_string_literal: true

require_relative "./base_page"

module Pages
  class SignInPage < ::Pages::BasePage
    set_url "/users/sign_in"
    set_primary_heading "Sign in"

    def find_out_how_to_get_access
      click_on "find out how to get access"

      Pages::CheckAccountPage.loaded
    end
  end
end
