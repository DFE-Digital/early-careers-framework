# frozen_string_literal: true

require_relative "./base"

module Pages
  class SignInPage < ::Pages::Base
    include Capybara::DSL

    def initialize
      @url = "/users/sign_in"
      @title = "Sign in"
    end

    def find_out_how_to_get_access
      click_on "find out how to get access"

      Pages::CheckAccountPage.new
    end
  end
end
