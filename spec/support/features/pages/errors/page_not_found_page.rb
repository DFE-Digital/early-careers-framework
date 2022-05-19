# frozen_string_literal: true

require_relative "../base"

module Pages
  class PageNotFoundPage < ::Pages::Base
    set_url "/404"
    set_primary_heading "Page not found"
  end
end
