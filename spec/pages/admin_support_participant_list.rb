# frozen_string_literal: true

module Pages
  class AdminSupportParticipantList
    include Capybara::DSL

    def view_participant(participant_name)
      click_on participant_name

      Pages::AdminSupportParticipantDetail.new
    end
  end
end
