# frozen_string_literal: true

require_relative "../base"

module Pages
  class AdminSupportPortal < ::Pages::Base
    include Capybara::DSL

    def view_participant_list
      click_on "Participants"

      Pages::AdminSupportParticipantList.new
    end
  end
end
