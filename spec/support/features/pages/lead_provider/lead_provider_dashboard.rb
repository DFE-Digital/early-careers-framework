# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class LeadProviderDashboard < ::Pages::BasePage
    set_url "/dashboard"
    # this is a hack as the lead providers name is the page title
    set_primary_heading(/^.*$/)

    def has_lead_provider_name?(lead_provider_name)
      primary_heading.has_content? lead_provider_name
    end

    def confirm_schools
      click_on "Confirm your schools"

      Pages::ConfirmSchoolsWizard.loaded
    end

    def check_schools
      click_on "Check your schools"

      Pages::CheckSchoolsPage.loaded
    end
  end
end
