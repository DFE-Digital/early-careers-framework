# frozen_string_literal: true

require_relative "../base"

module Pages
  class PageNotFoundPage < ::Pages::Base
    include Capybara::DSL

    def initialize
      @url = "/404"
      @title = "Page not found"
    end
  end
end
