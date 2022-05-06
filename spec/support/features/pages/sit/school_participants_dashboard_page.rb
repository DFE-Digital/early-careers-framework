# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantsDashboardPage < ::Pages::BasePage
    set_url "/schools/{slug}/cohorts/{cohort}/participants"
    set_primary_heading "Your ECTs and mentors"

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

      Pages::SchoolParticipantDetailsPage.loaded
    end

    def view_mentors(participant_name)
      within "#mentors" do
        click_on participant_name
      end

      Pages::SchoolParticipantDetailsPage.loaded
    end

    def view_not_training(participant_name)
      within "#not-training" do
        click_on participant_name
      end

      Pages::SchoolParticipantDetailsPage.loaded
    end
  end
end
