# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class EditSchoolParticipantNamePage < ::Pages::BasePage
    # Uncomment this line when FeatureFlag.active?(:cohortless_dashboard) gets removed and its code merged
    #   set_url "/schools/{slug}/participants/{participant_id}/edit-name"

    # Replace this line with
    #   set_url "/schools/{slug}/cohorts/{cohort}/participants/{participant_id}/edit-name"
    # if FeatureFlag.active?(:cohortless_dashboard) gets removed and its code removed (i.e. no cohortless in the service)
    set_url_matcher /schools\/([^\/]+)(\/cohorts\/([^\/]+))?\/participants\/([^\/]+)\/edit-name/

    set_primary_heading(/\AWhat should we edit (.*)’s name to\?\z/)

    def confirm_the_participant(name:)
      element_has_content?(header, "What should we edit #{name}’s name to?")
    end

    def set_a_blank_name
      fill_in("full_name", with: "")
      click_on("Continue")
    end

    def set_the_name(new_name:)
      fill_in("full_name", with: new_name)
      click_on("Continue")

      Pages::SchoolParticipantNameUpdatedPage.loaded
    end
  end
end
