# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantEmailUpdatedPage < ::Pages::BasePage
    set_url "/schools/{slug}/participants/{participant_id}/update-email"
    set_primary_heading(/\A(.*)’s email address has been updated\z/)

    def see_a_confirmation_message(name:)
      element_has_content?(header, "#{name}’s email address has been updated")
    end

    def return_to_the_ect_profile
      click_on "Return to their details"

      Pages::SchoolEarlyCareerTeacherDetailsPage.loaded
    end

    def return_to_the_mentor_profile
      click_on "Return to their details"

      Pages::SchoolMentorDetailsPage.loaded
    end

    def return_to_the_ects
      click_on "Return to your ECTs"

      Pages::SchoolEarlyCareerTeachersDashboardPage.loaded
    end
  end
end
