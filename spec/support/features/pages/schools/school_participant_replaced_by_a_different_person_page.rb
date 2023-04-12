# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantReplacedByADifferentPersonPage < ::Pages::BasePage
    # Uncomment this line when FeatureFlag.active?(:cohortless_dashboard) gets removed and its code merged
    #   set_url "/schools/{slug}/participants/{participant_id}/edit-name"

    # Replace this line with
    #   set_url "/schools/{slug}/cohorts/{cohort}/participants/{participant_id}/edit-name"
    # if FeatureFlag.active?(:cohortless_dashboard) gets removed and its code removed (i.e. no cohortless in the service)
    set_url_matcher(/schools\/([^\/]+)(\/cohorts\/([^\/]+))?\/participants\/([^\/]+)\/edit-name/)

    set_primary_heading(/\AYou cannot make that change by editing (.*)’s name\z/)

    def cant_edit_the_participant_name(name)
      element_has_content?(header, "You cannot make that change by editing #{name}’s name")
    end

    def can_add_a_participant(type)
      click_on "Add a new #{type}"

      element_has_content?(self, "Who do you want to add?") unless FeatureFlag.active?(:cohortless_dashboard)
    end
  end
end
