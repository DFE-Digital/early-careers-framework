# frozen_string_literal: true

require_relative "../base"

module Pages
  class SchoolPartnershipsPage < ::Pages::Base
    set_url "/schools/{slug}/cohorts/{cohort}/partnerships"
    set_primary_heading "Signed up with a training provider"

    def report_school_has_been_confirmed_incorrectly
      click_on "report that your school has been confirmed incorrectly"

      Pages::ReportIncorrectPartnershipPage.loaded
    end
  end
end
