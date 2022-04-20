# frozen_string_literal: true

require_relative "../base"

module Pages
  class SITParticipantDetails < ::Pages::Base
    include Capybara::DSL

    def can_see_email?(email)
      has_text?("Email address #{email}")
    end

    def can_see_full_name?(full_name)
      has_text?("Full name #{full_name}")
    end

    def can_see_status?(status)
      has_text?("Status\n#{status}")
    end
  end
end
