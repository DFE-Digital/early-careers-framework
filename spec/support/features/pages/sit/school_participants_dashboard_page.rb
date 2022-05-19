# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantsDashboardPage < ::Pages::BasePage
    set_url "/schools/{slug}/cohorts/{cohort}/participants"
    set_primary_heading "Your ECTs and mentors"

    def add_an_ect_or_mentor
      click_on "Add an ECT or mentor"
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
