# frozen_string_literal: true

require_relative "../base"

module Pages
  class SchoolPartnershipsPage < ::Pages::Base
    set_url "/schools/{slug}/cohorts/{cohort}/partnerships"
    set_primary_heading(/^Sign(?:ed|ing) up with a training provider$/)

    def report_school_partnership_has_been_confirmed_incorrectly
      click_on "report that your school has been confirmed incorrectly"

      Pages::ReportIncorrectPartnershipPage.loaded
    end

    def able_to_report_school_partnership_has_been_confirmed_incorrectly?
      has_selector?("a", text: "report that your school has been confirmed incorrectly")
    end
  end
end
