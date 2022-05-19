# frozen_string_literal: true

require_relative "../base"

module Pages
  class InternalServerErrorPage < ::Pages::Base
    set_url "/500"
    set_primary_heading "Sorry, there’s a problem with the service"
  end
end
