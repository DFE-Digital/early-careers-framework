# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantsDashboardPage < ::Pages::BasePage
    set_url "/schools/{slug}/participants"
    set_primary_heading "Manage mentors and ECTs"

    def choose_to_add_an_ect_or_mentor
      click_on "Add ECT or mentor"

      Pages::SchoolAddParticipantWizard.loaded
    end

    def view_ects(participant_name)
      click_on participant_name

      Pages::SchoolParticipantDetailsPage.loaded
    end

    def view_mentors(participant_name)
      click_on participant_name

      Pages::SchoolParticipantDetailsPage.loaded
    end

    def view_not_training(participant_name)
      click_on participant_name

      Pages::SchoolParticipantDetailsPage.loaded
    end
  end
end
