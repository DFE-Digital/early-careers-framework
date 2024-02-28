# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantNameUpdatedPage < ::Pages::BasePage
    set_url "/schools/{slug}/participants/{participant_id}/update-name"
    set_primary_heading(/\A(.*)’s name has been edited to (.*)\z/)

    def see_a_confirmation_message(old_name:, new_name:)
      element_has_content?(header, "#{old_name}’s name has been edited to #{new_name}")
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
      click_on("Return to manage ECTs")

      Pages::SchoolEarlyCareerTeachersDashboardPage.loaded
    end
  end
end
