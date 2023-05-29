# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class LeadProviderDashboard < ::Pages::BasePage
    set_url "/dashboard"
    # this is a hack as the lead providers name is the page title
    set_primary_heading(/^.*$/)

    def confirm_lead_provider_name(lead_provider_name)
      has_primary_heading? lead_provider_name

      self
    end

    def confirm_schools
      confirm_schools_for(Cohort.current)
    end

    def confirm_schools_for(cohort)
      click_on "Confirm your schools for the #{cohort.description} academic year"

      Pages::ConfirmSchoolsWizard.loaded
                                 .confirm_correct_academic_year(cohort)
    end

    def check_schools
      click_on "Check your schools"

      Pages::CheckSchoolsPage.loaded
    end
  end
end
