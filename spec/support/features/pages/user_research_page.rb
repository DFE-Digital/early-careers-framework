# frozen_string_literal: true

require_relative "./base_page"

module Pages
  class UserResearchPage < ::Pages::BasePage
    set_url "/pages/user-research{?mentor}"
    set_primary_heading "All research sessions are currently booked"
  end
end
