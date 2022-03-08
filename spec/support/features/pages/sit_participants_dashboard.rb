# frozen_string_literal: true

module Pages
  class SITParticipantsDashboard
    include Capybara::DSL

    def has_expected_content?
      has_selector?("h1", text: "Your ECTs and mentors") &&
        has_text?("Add a new ECT") &&
        has_text?("Add a new mentor") &&
        has_text?("Add yourself as a mentor")
    end

    def view_participant(participant_name)
      click_on participant_name

      Pages::SITParticipantDetails.new
    end
  end
end
