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

    def choose_to_transfer_an_ect_or_mentor
      click_on "Add ECT or mentor"

      Pages::SchoolTransferParticipantWizard.loaded
    end

    def visit_participant(participant_name)
      click_on participant_name

      Pages::SchoolParticipantDetailsPage.loaded
    end
  end
end
