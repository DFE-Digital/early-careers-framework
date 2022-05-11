# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolAddParticipantCompletedPage < ::Pages::BasePage
    set_url "/schools/{slug}/cohorts/{cohort}/participants/add/complete"
    set_primary_heading(/^.* has been added as (an ECT|a mentor)$/)

    def has_participant_name?(participant_name)
      element_has_content? header, "#{participant_name} has been added"
    end

    def has_participant_type?(participant_type)
      if participant_type == "ECT"
        element_has_content? header, "has been added as an ECT"
      else
        element_has_content? header, "has been added as a mentor"
      end
    end

    def view_your_ects_and_mentors
      click_on "View your ECTs and mentors"

      Pages::SchoolParticipantsDashboardPage.loaded
    end
  end
end
