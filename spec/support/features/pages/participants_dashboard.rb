# frozen_string_literal: true

module Pages
  class ParticipantsDashboard
    include Capybara::DSL
    include RSpec::Matchers

    def initialize
      expect(page).to have_selector("h1", text: "Your ECTs and mentors")
      expect(page).to have_text("Add a new ECT")
      expect(page).to have_text("Add a new mentor")
      expect(page).to have_text("Add yourself as a mentor")
    end

    def check_can_view_participants(*participants)
      participants.each do |participant|
        expect(page).to have_text(participant.user.full_name.to_s)
      end

      self
    end

    def check_cannot_view_participants(*participants)
      participants.each do |participant|
        expect(page).not_to have_text(participant.user.full_name.to_s)
      end

      self
    end
  end
end
