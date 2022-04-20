# frozen_string_literal: true

require_relative "./base"

module Pages
  class StartPage < ::Pages::Base
    include Capybara::DSL

    def initialize
      @url = "/"
      @title = "Manage training for early career teachers"
    end

    def start_now
      click_on "Start now"

      raise "Not yet implemented"
    end

    def view_accessibility_statement
      click_on "Accessibility"
    end
  end
end
