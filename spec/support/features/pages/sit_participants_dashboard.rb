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

    def view_ects(participant_name)
      within "#ects" do
        click_on participant_name
      end

      Pages::SITParticipantDetails.new
    end

    def view_mentors(participant_name)
      within "#mentors" do
        click_on participant_name
      end

      Pages::SITParticipantDetails.new
    end

    def view_not_training(participant_name)
      within "#not-training" do
        click_on participant_name
      end

      Pages::SITParticipantDetails.new
    end
  end
end
