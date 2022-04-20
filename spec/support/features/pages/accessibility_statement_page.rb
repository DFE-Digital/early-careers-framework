# frozen_string_literal: true

require_relative "./base"

module Pages
  class AccessibilityStatementPage < ::Pages::Base
    include Capybara::DSL

    def initialize
      @url = "/accessibility-statement"
      @title = "Accessibility statement"
    end
  end
end
