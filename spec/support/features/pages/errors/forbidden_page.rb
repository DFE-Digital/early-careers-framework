# frozen_string_literal: true

require_relative "../base"

module Pages
  class ForbiddenPage < ::Pages::Base
    set_url "/403"
    set_primary_heading "Page not found"
  end
end
