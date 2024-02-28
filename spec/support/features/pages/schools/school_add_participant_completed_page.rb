# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolAddParticipantCompletedPage < ::Pages::BasePage
    set_url "/schools/{slug}/participants/add/complete"
    set_primary_heading(/^.* has been added as (an ECT|a mentor)$/)

    def confirm_has_full_name(full_name)
      element_has_content? header, "#{full_name} has been added"
      self
    end

    def confirm_has_participant_type(participant_type)
      if participant_type == "ECT"
        element_has_content? header, "has been added as an ECT"
      else
        element_has_content? header, "has been added as a mentor"
      end
      self
    end

    def view_your_ects
      click_on "View your ECTs"

      Pages::SchoolEarlyCareerTeachersDashboardPage.loaded
    end

    def view_your_mentors
      click_on "View your mentors"

      Pages::SchoolMentorsDashboardPage.loaded
    end
  end
end
