# frozen_string_literal: true

module Pages
  class AdminSupportParticipantDetail
    include Capybara::DSL

    def can_see_eligible_to_start?(participant_name)
      has_text? "#{participant_name} Eligible to start"
    end

    def can_see_full_name?(participant_name)
      has_text? "Full name #{participant_name}"
    end

    def can_see_school?(school_name)
      has_text? "School #{school_name}"
    end
  end
end
