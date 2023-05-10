# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class LeadProviderDashboard < ::Pages::BasePage
    set_url "/dashboard"
    # this is a hack as the lead providers name is the page title
    set_primary_heading(/^.*$/)

    def confirm_lead_provider_name(lead_provider_name)
      has_primary_heading? lead_provider_name
    end

    def confirm_schools(academic_year = nil)
      academic_year ||= Cohort.current
      click_on "Confirm your schools for the #{academic_year.description} academic year"

      Pages::ConfirmSchoolsWizard.loaded
    end

    def check_schools
      click_on "Check your schools"

      Pages::CheckSchoolsPage.loaded
    end
  end
end
