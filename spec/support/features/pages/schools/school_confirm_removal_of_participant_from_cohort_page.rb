# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolConfirmRemovalOfParticipantFromCohortPage < ::Pages::BasePage
    # Uncomment this line when FeatureFlag.active?(:cohortless_dashboard) gets removed and its code merged
    #   set_url "/schools/{slug}/participants/{participant_id}/remove"

    # Replace this line with
    #   set_url "/schools/{slug}/cohorts/{cohort}/participants/{participant_id}/remove"
    # if FeatureFlag.active?(:cohortless_dashboard) gets removed and its code removed (i.e. no cohortless in the service)
    set_url_matcher(/schools\/([^\/]+)(\/cohorts\/([^\/]+))?\/participants\/([^\/]+)\/remove/)

    set_primary_heading(/\AConfirm you want to remove (.*)\z/)
  end
end
