# frozen_string_literal: true

require_relative "../base"

module Pages
  class AdminSupportParticipantList < ::Pages::Base
    include Capybara::DSL

    def view_participant(participant_name)
      click_on participant_name

      Pages::AdminSupportParticipantDetail.new
    end
  end
end
