# frozen_string_literal: true

require_relative "../base"

module Pages
  class ForbiddenPage < ::Pages::Base
    include Capybara::DSL

    def initialize
      @url = "/403"
      @title = "Page not found"
    end
  end
end
