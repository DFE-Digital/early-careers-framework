# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolAddParticipantStartPage < ::Pages::BasePage
    set_url "/schools/{slug}/cohorts/{cohort}/roles"
    set_primary_heading "Check what each person needs to do in the early career teacher training programme"

    def continue
      click_on "Continue"

      Pages::SchoolParticipantsDashboardPage.loaded
    end
  end
end
