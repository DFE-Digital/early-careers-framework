# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantNameUpdatedPage < ::Pages::BasePage
    # Uncomment this line when FeatureFlag.active?(:cohortless_dashboard) gets removed and its code merged
    #   set_url "/schools/{slug}/participants/{participant_id}/update-name"

    # Replace this line with
    #   set_url "/schools/{slug}/cohorts/{cohort}/participants/{participant_id}/update-name"
    # if FeatureFlag.active?(:cohortless_dashboard) gets removed and its code removed (i.e. no cohortless in the service)
    set_url_matcher(/schools\/([^\/]+)(\/cohorts\/([^\/]+))?\/participants\/([^\/]+)\/update-name/)

    set_primary_heading(/\A(.*)’s name has been edited to (.*)\z/)

    def see_a_confirmation_message(old_name:, new_name:)
      element_has_content?(header, "#{old_name}’s name has been edited to #{new_name}")
    end

    def return_to_the_participant_profile
      click_on "Return to their details"

      Pages::SchoolParticipantDetailsPage.loaded
    end

    def return_to_the_ect_and_mentors
      click_on(FeatureFlag.active?(:cohortless_dashboard) ? "Return to manage mentors and ECTs" : "Return to your ECTs and mentors")

      Pages::SchoolParticipantsDashboardPage.loaded
    end
  end
end
