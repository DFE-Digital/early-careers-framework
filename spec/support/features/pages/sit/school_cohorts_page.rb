# frozen_string_literal: true

require_relative "../base"

module Pages
  class SchoolCohortsPage < ::Pages::Base
    set_url "/schools/{slug}/cohorts/{cohort}"
    set_primary_heading "Choose an induction programme"

    def report_school_has_been_confirmed_incorrectly
      click_on "report that your school has been confirmed incorrectly"

      Pages::ReportIncorrectPartnershipPage.loaded
    end

    def enter_partnership_details_url
      visit "#{current_url}/partnerships"

      Pages::SchoolPartnershipsPage.loaded
    end
  end
end
