# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantShouldNotHaveBeenRegisteredPage < ::Pages::BasePage
    # Uncomment this line when FeatureFlag.active?(:cohortless_dashboard) gets removed and its code merged
    #   set_url "/schools/{slug}/participants/{participant_id}/edit-name"

    # Replace this line with
    #   set_url "/schools/{slug}/cohorts/{cohort}/participants/{participant_id}/edit-name"
    # if FeatureFlag.active?(:cohortless_dashboard) gets removed and its code removed (i.e. no cohortless in the service)
    set_url_matcher /schools\/([^\/]+)(\/cohorts\/([^\/]+))?\/participants\/([^\/]+)\/edit-name/

    set_primary_heading(/\AYou cannot make that change by editing (.*)’s name\z/)

    def cant_edit_the_participant_name(name)
      element_has_content?(header, "You cannot make that change by editing #{name}’s name")
    end

    def can_remove_the_participant(name)
      click_on "remove all their information from this service."

      Pages::SchoolConfirmRemovalOfParticipantFromCohortPage.loaded
      element_has_content?(self, "Confirm you want to remove #{name}")
    end

    def return_to_the_ect_and_mentors
      click_on "Return to your ECTs and mentors"

      Pages::SchoolParticipantsDashboardPage.loaded
    end
  end
end
