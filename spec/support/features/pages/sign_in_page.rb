# frozen_string_literal: true

require_relative "./base"

module Pages
  class SignInPage < ::Pages::Base
    set_url "/users/sign_in"
    set_primary_heading "Sign in"

    def find_out_how_to_get_access
      click_on "find out how to get access"

      Pages::CheckAccountPage.new
    end
  end
end
