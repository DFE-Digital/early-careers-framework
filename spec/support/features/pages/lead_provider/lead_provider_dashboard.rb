# frozen_string_literal: true

require_relative "../base"

module Pages
  class LeadProviderDashboard < ::Pages::Base
    set_url "/dashboard"
    set_primary_heading "Lead Provider Dashboard"

    def start_confirm_your_schools_wizard
      click_on "Confirm your schools"

      Pages::LeadProviderConfirmYourSchoolsWizard.new
    end

    def check_schools_for_2021
      click_on "Check your schools for 2021"

      Pages::LeadProviderSchoolsDashboard.new
    end
  end
end
