# frozen_string_literal: true

module Pages
  class SITParticipantDetails
    include Capybara::DSL

    def can_see_email?(email)
      has_text?("Email address #{email}")
    end

    def can_see_full_name?(full_name)
      has_text?("Full name #{full_name}")
    end

    def can_see_status?(status)
      # TODO: not sure where a school can see this
      has_text?("Status\n#{status}")
    end
  end
end
