# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantDetailsPage < ::Pages::BasePage
    # Uncomment this line when FeatureFlag.active?(:cohortless_dashboard) gets removed and its code merged
    #   set_url "/schools/{slug}/participants/{participant_id}"

    # Replace this line with
    #   set_url "/schools/{slug}/cohorts/{cohort}/participants/{participant_id}"
    # if FeatureFlag.active?(:cohortless_dashboard) gets removed and its code removed (i.e. no cohortless in the service)
    set_url_matcher /schools\/([^\/]+)(\/cohorts\/([^\/]+))?\/participants\/([^\/]+)/

    # this is a hack as the participants name is the page title
    set_primary_heading(/^.*$/)

    def confirm_the_participant(name:)
      has_primary_heading? name
    end

    def confirm_email_address(email)
      element_has_content? self, "Email address #{email}"
    end

    def confirm_full_name(full_name)
      element_has_content? self, "Name #{full_name}"
    end

    def confirm_status(status)
      element_has_content? self, "Status\n#{status}"
    end
  end
end
