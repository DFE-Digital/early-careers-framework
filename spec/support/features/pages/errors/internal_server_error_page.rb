# frozen_string_literal: true

require_relative "../base"

module Pages
  class InternalServerErrorPage < ::Pages::Base
    include Capybara::DSL

    def initialize
      @url = "/500"
      @title = "Sorry, there’s a problem with the service"
    end
  end
end
